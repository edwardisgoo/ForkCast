import { ai } from "../../config";
import { z } from 'zod';
import { GooglePlacesService } from '../services/GooglePlacesService';
import * as functions from 'firebase-functions';

import {
  BusinessStatus,
  PriceLevel
} from '../services/GooglePlacesTypes';

const API = "AIzaSyBKQqbW8A7wIbwRN6ebdelrpn-eV9SFtno";
const service = new GooglePlacesService(API);

// Input Schema
const RestaurantQuerySchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  minPrice: z.number().min(0).optional(),
  maxPrice: z.number().min(0).optional(),
  minDistance: z.number().min(0).optional(),
  maxDistance: z.number().min(0).optional(),
  requirement: z.string().optional(), // Currently unused
  note: z.string().optional() // Currently unused
});

// Output Schema
const RestaurantRawSchema = z.object({
  id: z.string(),
  name: z.string(),
  address: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  businessStatus: z.nativeEnum(BusinessStatus),
  openingHours: z.array(
    z.object({
      start: z.object({ hour: z.number(), minute: z.number() }),
      end: z.object({ hour: z.number(), minute: z.number() })
    })
  ).optional(),
  rating: z.number().optional(),
  reviews: z.array(
    z.object({
      authorName: z.string().optional(),
      rating: z.number(),
      time: z.number(),
      text: z.string(),
      language: z.string().optional()
    })
  ),
  photos: z.array(z.string()),
  types: z.instanceof(Set<number>),
  url: z.string().url().optional(),
  priceLevel: z.nativeEnum(PriceLevel).optional(),
  // Amenities
  dineIn: z.boolean(),
  takeout: z.boolean(),
  delivery: z.boolean(),
  reservable: z.boolean(),
  servesBeer: z.boolean(),
  servesWine: z.boolean(),
  wheelchairAccessibleEntrance: z.boolean()
});

export const placesGetRestaurantRawFlow = ai.defineFlow(
  {
    name: 'placesGetRestaurantRaw',
    inputSchema: RestaurantQuerySchema,
    outputSchema: z.array(RestaurantRawSchema),
  },
  async (params) => {
    // Convert NTD to Google's price level (0-4)
    const priceLevels = convertNtdToPriceLevel(params.minPrice, params.maxPrice);
    
    // Perform nearby search
    const nearbyParams = {
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.maxDistance ? params.maxDistance : 5000, // Convert km to meters
      minprice: priceLevels.min,
      maxprice: priceLevels.max,
      type: 'restaurant'
    };
    
    let results = await service.nearbySearch(nearbyParams);
    
    // Filter by min distance if specified
    if (params.minDistance) {
      results = results.filter(place => 
        calculateDistance(
          params.latitude, 
          params.longitude,
          place.latitude,
          place.longitude
        ) >= (params.minDistance || 0)
      );
    }
    
    // Get details for each restaurant (limited to 10 for performance)
    const detailedResults = await Promise.all(
      results.slice(0, 10).map(place => 
        service.detailsSearch({ placeId: place.id })
      )
    );
    
    return detailedResults.map(details => ({
      id: details.id,
      name: details.name,
      address: details.formattedAddress || details.address,
      latitude: details.latitude,
      longitude: details.longitude,
      businessStatus: details.businessStatus,
      openingHours: details.openingHours,
      rating: details.rating,
      reviews: details.reviews,
      photos: details.photos,
      types: details.types,
      url: details.url,
      priceLevel: details.priceLevel,
      dineIn: details.dineIn,
      takeout: details.takeout,
      delivery: details.delivery,
      reservable: details.reservable,
      servesBeer: details.servesBeer,
      servesWine: details.servesWine,
      wheelchairAccessibleEntrance: details.wheelchairAccessibleEntrance
    }));
  }
);

// Helper function to convert NTD to Google's price level
function convertNtdToPriceLevel(min?: number, max?: number): { min: PriceLevel, max: PriceLevel } {
  // Simple conversion - adjust based on your needs
  const convert = (amount?: number): PriceLevel => {
    if (!amount) return PriceLevel.MODERATE;
    if (amount <= 50) return PriceLevel.FREE;
    if (amount <= 200) return PriceLevel.INEXPENSIVE;
    if (amount <= 400) return PriceLevel.MODERATE;
    if (amount <= 1000) return PriceLevel.EXPENSIVE;
    return PriceLevel.VERY_EXPENSIVE;
  };
  
  return {
    min: convert(min),
    max: convert(max)
  };
}

// Helper function to calculate distance between two coordinates (in km)
function calculateDistance(lat1: number, lon1: number, lat2: number, lon2: number): number {
  const R = 6371; // Earth's radius in km
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLon = (lon2 - lon1) * Math.PI / 180;
  const a = 
    Math.sin(dLat/2) * Math.sin(dLat/2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLon/2) * Math.sin(dLon/2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
  return R * c;
}

// Standard Cloud Function version
export const getRestaurantRawFunction = functions.https.onCall(
  async (data: unknown, context) => {
    const params = RestaurantQuerySchema.parse(data);
    const flow = await placesGetRestaurantRawFlow(params);
    return flow;
  }
);