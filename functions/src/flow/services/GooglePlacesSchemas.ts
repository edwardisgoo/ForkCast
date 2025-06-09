import { z } from 'zod';
import {
  PriceLevel,
  BusinessStatus,
  type NearbySearchParams,
  type DetailsSearchParams
} from './GooglePlacesTypes';

// Input Schema
export const NearbySearchParamsSchema = z.object({
  latitude: z.number().min(-90).max(90),
  longitude: z.number().min(-180).max(180),
  radius: z.number().min(0).max(50000).optional(),  // Required if not using rankby=distance
  rankby: z.enum(['prominence', 'distance']).optional(), // New field
  maxResults: z.number().min(1).max(60).optional(), // New field (Google's max is 60)
  type: z.string().optional(),
  keyword: z.string().optional(),
  minprice: z.nativeEnum(PriceLevel).optional(),
  maxprice: z.nativeEnum(PriceLevel).optional(),
  opennow: z.boolean().optional()
}).superRefine((data, ctx) => {
  // Custom validation: radius is required unless rankby=distance
  if (!data.rankby && !data.radius) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: "Either 'radius' or 'rankby=distance' must be provided",
      path: ['radius']
    });
  }
  if (data.rankby === 'distance' && !data.keyword && !data.type) {
    ctx.addIssue({
      code: z.ZodIssueCode.custom,
      message: "When rankby=distance, you must provide either 'keyword' or 'type'",
      path: ['rankby']
    });
  }
}) satisfies z.ZodType<NearbySearchParams>;

export const DetailsSearchParamsSchema = z.object({
  placeId: z.string(),
  fields: z.string().optional()
}) satisfies z.ZodType<DetailsSearchParams>;

// Output Schema
const PlaceBasicSchema = z.object({
  id: z.string(),
  name: z.string(),
  address: z.string(),
  latitude: z.number(),
  longitude: z.number(),
  types: z.instanceof(Set<number>),
  photos: z.array(z.string()),
  rating: z.number().optional(),
  priceLevel: z.nativeEnum(PriceLevel).optional(),
  businessStatus: z.nativeEnum(BusinessStatus),
  openingHours: z.array(
    z.object({
      start: z.object({ hour: z.number(), minute: z.number() }),
      end: z.object({ hour: z.number(), minute: z.number() })
    })
  ).optional(),
});

// Nearby 搜尋專用 Schema
export const NearbyPlaceSchema = PlaceBasicSchema.extend({
  vicinity: z.string(),
  userRatingsTotal: z.number().optional(),
});

// Details 搜尋專用 Schema
export const PlaceDetailsSchema = PlaceBasicSchema.extend({
  formattedAddress: z.string(),
  internationalPhoneNumber: z.string().optional(),
  website: z.string().url().optional(),
  reviews: z.array(
    z.object({
      authorName: z.string().optional(),
      rating: z.number(),
      time: z.number(),
      text: z.string(),
      language: z.string().optional()
    })
  ),
  currentOpeningHours: z.object({
    openNow: z.boolean(),
    periods: z.array(
      z.object({
        start: z.object({ hour: z.number(), minute: z.number() }),
        end: z.object({ hour: z.number(), minute: z.number() })
      })
    ),
    weekdayText: z.array(z.string())
  }).optional(),
  // 服務設施
  dineIn: z.boolean(),
  takeout: z.boolean(),
  delivery: z.boolean(),
  reservable: z.boolean(),
  servesBeer: z.boolean(),
  servesWine: z.boolean(),
  // 其他詳細欄位
  editorialSummary: z.string().optional(),
  url: z.string().url().optional(),
  wheelchairAccessibleEntrance: z.boolean()
});


//重要schema

export const RestaurantRawSchema = z.object({
    id: z.string(),
    name: z.string(),
    address: z.string(),
    latitude: z.number(),
    longitude: z.number(),
    businessStatus: z.nativeEnum(BusinessStatus),
    openingHours: z.array(
        z.object({
            day: z.number().min(0).max(6),
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
    phoneNumber: z.string().optional(),
    photos: z.array(z.string()),
    types: z.instanceof(Set),
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