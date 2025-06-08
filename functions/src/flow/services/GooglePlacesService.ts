// src/services/GooglePlacesService.ts

import {
    PlacesApiResponse,
    PlaceBasic,
    NearbyPlace,
    PlaceDetails,
    NearbySearchParams,
    DetailsSearchParams,
    CurrentOpeningHoursRaw, // 導入原始 current_opening_hours 類型
} from './GooglePlacesTypes';

import {
    parseBusinessStatus,
    parsePriceLevel,
    parseOpeningHours, // 確保導入
    parseReviews,
    parseTypes
} from './GooglePlacesUtils';

// You might need to import API from your config.ts
// import { API } from '../config'; // Assuming API key is in config.ts or passed in

export class GooglePlacesService {
    private apiKey: string;
    // Assuming you have a basic HTTP client library or you use fetch directly
    // private client: AxiosInstance; // If using axios or similar

    constructor(apiKey: string) {
        if (!apiKey) throw new Error('Google Places API key is required');
        this.apiKey = apiKey;
        // this.client = axios.create({ baseURL: 'https://maps.googleapis.com/maps/api/place/' });
    }

    // Helper to make API requests using native fetch
    private async makeApiRequest<T>(url: string): Promise<T> {
        const response = await fetch(url);
        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`API request failed with status ${response.status}: ${errorText}`);
        }
        const data = await response.json();
        return data as T;
    }

    async nearbySearch(params: NearbySearchParams): Promise<NearbyPlace[]> {
        const {
            latitude,
            longitude,
            radius,
            rankby,
            maxResults = 20,
            ...rest
        } = params;

        if (rankby === 'distance' && radius) {
            console.warn("'radius' will be ignored when rankby=distance in nearby search.");
        }

        let url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${latitude},${longitude}&key=${this.apiKey}`;

        if (rankby === 'distance') {
            url += `&rankby=distance`;
        } else {
            url += `&radius=${radius || 5000}`;
        }

        Object.entries(rest).forEach(([key, value]) => {
            if (value !== undefined) url += `&${key}=${encodeURIComponent(String(value))}`;
        });

        try {
            let allResults: NearbyPlace[] = [];
            let nextPageToken: string | undefined;
            let counter = 0; // To prevent infinite loops in case of bad next_page_token handling

            do {
                if (nextPageToken) {
                    url = `https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=${nextPageToken}&key=${this.apiKey}`;
                    await new Promise(resolve => setTimeout(resolve, 2000)); // Required delay for pagination
                }

                const response = await this.makeApiRequest<PlacesApiResponse<any>>(url); // Use any for raw results

                if (response.results) {
                    allResults.push(...response.results.map(this.transformToNearbyPlace));
                }

                nextPageToken = response.next_page_token;

                if (maxResults && allResults.length >= maxResults) break;
                counter++;
                if (counter > 5) { // Limit pagination to avoid excessive calls
                    console.warn("Reached max pagination limit (5 pages). Stopping nearby search.");
                    break;
                }

            } while (nextPageToken);

            return maxResults ? allResults.slice(0, maxResults) : allResults;
        } catch (error) {
            console.error('Nearby search failed:', error);
            throw error;
        }
    }

    async detailsSearch(params: DetailsSearchParams): Promise<PlaceDetails> {
        const { placeId, fields } = params;
        // Request comprehensive fields including opening_hours.periods
        const defaultFields = 'place_id,name,formatted_address,geometry,business_status,opening_hours,rating,reviews,photos,types,url,price_level,current_opening_hours,dine_in,takeout,delivery,reservable,serves_beer,serves_wine,wheelchair_accessible_entrance,international_phone_number,website,editorial_summary';
        const finalFields = fields || defaultFields;

        let url = `https://maps.googleapis.com/maps/api/place/details/json?place_id=${placeId}&language=zh-TW&key=${this.apiKey}&fields=${encodeURIComponent(finalFields)}`;

        try {
            const response = await this.makeApiRequest<PlacesApiResponse<any>>(url); // Use any for raw result

            if (!response.result) {
                throw new Error(`No result data found for placeId: ${placeId}`);
            }

            return this.transformToPlaceDetails(response.result);
        } catch (error) {
            console.error(`Details search for placeId ${placeId} failed:`, error);
            throw error;
        }
    }

    // Helper to extract common basic fields from raw API response objects
    private extractBasicFields(place: any): PlaceBasic {
        return {
            id: place.place_id || '',
            name: place.name || 'Unknown',
            address: place.vicinity || place.formatted_address || '', // Prioritize formatted_address if available
            latitude: place.geometry?.location?.lat || 0,
            longitude: place.geometry?.location?.lng || 0,
            // Pass raw types array to parseTypes
            types: parseTypes(place.types),
            photos: place.photos?.map((p: any) => p.photo_reference) || [],
            rating: place.rating,
            priceLevel: parsePriceLevel(place.price_level),
            businessStatus: parseBusinessStatus(place.business_status),
            // Use parseOpeningHours to transform raw opening_hours.periods to TimePeriod[]
            openingHours: parseOpeningHours(place.opening_hours?.periods)
        };
    }

    // Transforms raw Nearby Search result to NearbyPlace
    public transformToNearbyPlace = (place: any): NearbyPlace => {
        const basicFields = this.extractBasicFields(place);
        return {
            ...basicFields,
            vicinity: place.vicinity || '',
            userRatingsTotal: place.user_ratings_total
        };
    }

    // Transforms raw Details Search result to PlaceDetails
    public transformToPlaceDetails(details: any): PlaceDetails {
        const basicFields = this.extractBasicFields(details);

        // Safely parse current_opening_hours if available
        const currentOpeningHoursData = details.current_opening_hours as CurrentOpeningHoursRaw | undefined;
        const currentOpeningHours = currentOpeningHoursData ? {
            openNow: currentOpeningHoursData.open_now || false,
            // Use parseOpeningHours to transform raw periods to TimePeriod[]
            periods: parseOpeningHours(currentOpeningHoursData.periods) || [], // Ensure it's an array if undefined
            weekdayText: currentOpeningHoursData.weekday_text || []
        } : undefined;

        return {
            ...basicFields,
            formattedAddress: details.formatted_address || '',
            internationalPhoneNumber: details.international_phone_number,
            website: details.website,
            reviews: parseReviews(details.reviews), // Use parseReviews
            dineIn: details.dine_in || false,
            takeout: details.takeout || false,
            delivery: details.delivery || false,
            reservable: details.reservable || false,
            servesBeer: details.serves_beer || false,
            servesWine: details.serves_wine || false,
            wheelchairAccessibleEntrance: details.wheelchair_accessible_entrance || false,
            editorialSummary: details.editorial_summary?.overview,
            url: details.url || details.website || '', // Prefer url, fallback to website
            currentOpeningHours: currentOpeningHours // Assign the transformed currentOpeningHours
        };
    }
}