import { ai, API } from "../../config";
import { z } from 'zod';
import { GooglePlacesService } from '../services/GooglePlacesService';
import * as functions from 'firebase-functions';
import { RestaurantRawSchema } from "../services/GooglePlacesSchemas";
import  {restaurantKeywords} from "../services/restaurantKeyword";

import {
  PriceLevel
} from '../services/GooglePlacesTypes';

const service = new GooglePlacesService(API);

// Updated Input Schema
export const RestaurantQuerySchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  minPrice: z.number().min(0).optional(),
  maxPrice: z.number().min(0).optional(),
  minDistance: z.number().min(0).optional(),
  maxDistance: z.number().min(0).optional(),
  requirement: z.string().optional(),
  note: z.string().optional(),
  unwanted_restaurants: z.array(z.string()).optional().default([])
});

function extractRestaurantKeyword(requirement?: string): string {
  if (!requirement) return "";

  for (const keyword of restaurantKeywords) {
    if (requirement.includes(keyword)) {
      return keyword;
    }
  }
  return "";
}

// Updated flow implementation
export const placesGetRestaurantRawFlow = ai.defineFlow(
  {
    name: 'placesGetRestaurantRaw',
    inputSchema: RestaurantQuerySchema,
    outputSchema: z.array(RestaurantRawSchema),
  },
  async (params) => {
    // Convert NTD to Google's price level (0-4)
    const priceLevels = convertNtdToPriceLevel(params.minPrice, params.maxPrice);

    // Extract keyword from requirement
    const keyword = extractRestaurantKeyword(params.requirement);

    // Perform nearby search
    const nearbyParams = {
      latitude: params.latitude,
      longitude: params.longitude,
      radius: params.maxDistance ? params.maxDistance : 5000,
      minprice: priceLevels.min,
      maxprice: priceLevels.max,
      type: 'restaurant',
      keyword: keyword === "" ? undefined : keyword, // Add the extracted keyword here
      maxResults: 60,
      opennow: true
    };

    let results = await service.nearbySearch(nearbyParams);
    let numNearbysearch = results.length;

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

    // Filter out unwanted restaurants
    if (params.unwanted_restaurants && params.unwanted_restaurants.length > 0) {
      results = results.filter(place =>
        !params.unwanted_restaurants?.includes(place.id)
      );
    }

    let numFilteredNearbysearch = results.length;
    if (numFilteredNearbysearch === 0) {
      throw new Error(
        `placesGetRestaurantRawFlow內將${numNearbysearch}家餐廳filter到剩下0家餐廳\n` +
        `過濾條件:\n` +
        `- 最小距離: ${params.minDistance || '未指定'}km\n` +
        `- 排除餐廳數量: ${params.unwanted_restaurants?.length || 0}\n` +
        `- 搜尋關鍵字: ${keyword === "" ? '無' : keyword}`
      );
    }

    const shuffled = results.sort(() => 0.5 - Math.random());
    const selected = shuffled.slice(0, 10);
    // Get details for selected random restaurants
    const detailedResults = await Promise.all(
      selected.map(place =>
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
      phoneNumber: details.internationalPhoneNumber,
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
    if (amount === undefined || amount === null) return PriceLevel.MODERATE; // Default to moderate if undefined
    if (amount <= 20) return PriceLevel.FREE;
    if (amount <= 50) return PriceLevel.INEXPENSIVE;
    if (amount <= 1000) return PriceLevel.MODERATE;
    if (amount <= 3000) return PriceLevel.EXPENSIVE;
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
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) *
    Math.sin(dLon / 2) * Math.sin(dLon / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
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