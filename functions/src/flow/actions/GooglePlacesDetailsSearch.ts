import { ai } from "../../config";
// import { z } from 'zod';
import { GooglePlacesService } from '../services/GooglePlacesService';
import { DetailsSearchParamsSchema, PlaceDetailsSchema } from '../services/GooglePlacesSchemas';
import * as functions from 'firebase-functions';

const API = "AIzaSyBKQqbW8A7wIbwRN6ebdelrpn-eV9SFtno";
// const API = process.env.GOOGLE_PLACES_API_KEY;
const service = new GooglePlacesService(API);

export const placesDetailsSearchFlow = ai.defineFlow(
  {
    name: 'placesDetailsSearch',
    inputSchema: DetailsSearchParamsSchema,
    outputSchema: PlaceDetailsSchema, // 使用 Details 專用 Schema
  },
  async (params) => {
    const result = await service.detailsSearch(params);
    return result;
  }
);

// 普通 Cloud Function 版本
export const detailsSearchFunction = functions.https.onCall(
  async (data: unknown, context) => {
    const params = DetailsSearchParamsSchema.parse(data);
    return await service.detailsSearch(params);
  }
);