import {
  PlacesApiResponse,
  PlaceBasic,
  NearbyPlace,
  PlaceDetails,
  NearbySearchParams,
  DetailsSearchParams
} from './GooglePlacesTypes';


import {
  parseBusinessStatus,
  parsePriceLevel,
  parseOpeningHours,
  parseReviews,
  parseTypes
} from './GooglePlacesUtils';



export class GooglePlacesService {
  private apiKey: string;

  constructor(apiKey: string) {
    if (!apiKey) throw new Error('Google Places API key is required');
    this.apiKey = apiKey;
  }

  async nearbySearch(params: NearbySearchParams): Promise<NearbyPlace[]> {
    const {
      latitude,
      longitude,
      radius,
      rankby,
      maxResults = 20, // Default to 20 if not specified
      ...rest
    } = params;

    // Validate mutually exclusive params
    if (rankby === 'distance' && radius) {
      console.warn("'radius' will be ignored when rankby=distance");
    }

    let url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&key=${this.apiKey}`;

    // Handle rankby vs radius
    if (rankby === 'distance') {
      url += `&rankby=distance`;
    } else {
      url += `&radius=${radius || 5000}`; // Default radius if not provided
    }

    // Add other optional params
    Object.entries(rest).forEach(([key, value]) => {
      if (value !== undefined) url += `&${key}=${encodeURIComponent(String(value))}`;
    });

    try {
      let allResults: NearbyPlace[] = [];
      let nextPageToken: string | undefined;

      do {
        if (nextPageToken) {
          url += `&pagetoken=${nextPageToken}`;
          await new Promise(resolve => setTimeout(resolve, 2000)); // Required delay
        }

        const response = await this.makeApiRequest<PlacesApiResponse<NearbyPlace>>(url);

        if (response.results) {
          allResults.push(...response.results.map(this.transformToNearbyPlace));
        }

        nextPageToken = response.next_page_token;

        // Early exit if we've collected enough results
        if (maxResults && allResults.length >= maxResults) break;

      } while (nextPageToken);

      return maxResults ? allResults.slice(0, maxResults) : allResults;
    } catch (error) {
      console.error('Nearby search failed:', error);
      throw error;
    }
  }

  async detailsSearch(params: DetailsSearchParams): Promise<PlaceDetails> {

    //call api
    const { placeId, fields } = params;
    let url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&language=zh-TW&key=${this.apiKey}`;

    if (fields) url += `&fields=${encodeURIComponent(fields)}`;

    // catch error
    try {
      const response = await this.makeApiRequest<PlacesApiResponse<PlaceDetails>>(url);

      if (!response.result) {
        throw new Error('No result data in API response');
      }

      return this.transformToPlaceDetails(response.result);
    } catch (error) {
      console.error('Details search failed:', error);
      throw error;
    }
  }

  private async makeApiRequest<T>(url: string): Promise<T> {
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`API request failed with status ${response.status}`);
    }

    const data = await response.json() as T;
    return data;
  }


  private extractBasicFields(place: any): PlaceBasic {
    return {
      id: place.place_id || '',
      name: place.name || 'Unknown',
      address: place.vicinity || place.formatted_address || '',
      latitude: place.geometry?.location?.lat || 0,
      longitude: place.geometry?.location?.lng || 0,
      types: parseTypes(place.types),
      photos: place.photos?.map((p: any) => p.photo_reference) || [],
      rating: place.rating,
      priceLevel: place.price_level !== undefined ?
        parsePriceLevel(place.price_level) : undefined,
      businessStatus: parseBusinessStatus(place.business_status),
      openingHours: parseOpeningHours(
        place.current_opening_hours?.periods ||
        place.opening_hours?.periods
      )
    };
  }


  public transformToNearbyPlace = (place: any): NearbyPlace => {
    const basicFields = this.extractBasicFields(place);
    return {
      ...basicFields,
      vicinity: place.vicinity || '',
      userRatingsTotal: place.user_ratings_total
    };
  }

  public transformToPlaceDetails(details: any): PlaceDetails {
    const basicFields = this.extractBasicFields(details);

    return {
      ...basicFields,
      formattedAddress: details.formatted_address || '',
      internationalPhoneNumber: details.international_phone_number,
      website: details.website,
      reviews: parseReviews(details.reviews),
      currentOpeningHours: details.current_opening_hours ? {
        openNow: details.current_opening_hours.open_now,
        periods: parseOpeningHours(details.current_opening_hours.periods),
        weekdayText: details.current_opening_hours.weekday_text || []
      } : undefined,
      // Amenities
      dineIn: details.dine_in || false,
      takeout: details.takeout || false,
      delivery: details.delivery || false,
      reservable: details.reservable || false,
      servesBeer: details.serves_beer || false,
      servesWine: details.serves_wine || false,
      // Additional fields
      editorialSummary: details.editorial_summary?.overview,
      url: details.url || details.website || '',
      wheelchairAccessibleEntrance: details.wheelchair_accessible_entrance || false
    };
  }
}