import { ai,API } from "../../config";
import { z } from 'zod';
import { GooglePlacesService } from '../services/GooglePlacesService';
import { NearbySearchParamsSchema,NearbyPlaceSchema } from '../services/GooglePlacesSchemas';
import * as functions from 'firebase-functions';

const service = new GooglePlacesService(API);

export const placesNearbySearchFlow = ai.defineFlow(
  {
    name: 'placesNearbySearch',
    inputSchema: NearbySearchParamsSchema,
    outputSchema: z.array(NearbyPlaceSchema), // 使用 Nearby 專用 Schema
  },
  async (params) => {
    const results = await service.nearbySearch(params);
    return results;
  }
);

// 普通 Cloud Function 版本
export const nearbySearchFunction = functions.https.onCall(
  async (data: unknown, context) => {
    const params = NearbySearchParamsSchema.parse(data);
    return await service.nearbySearch(params);
  }
);