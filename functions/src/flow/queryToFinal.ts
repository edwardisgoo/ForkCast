import { z } from "genkit";
import { ai } from "../config";
import { restaurantQueryFlow} from './queryToRestaurantInput'; // Flow 5
import { findRestaurantsFlow, QuerySchema, UserSettingSchema, RecommendationSchema } from './findRestaurants'; // Flow 6
import { detailGenerationFlow, DetailSchema } from './detailGeneration'; // Flow 7
import { RestaurantQuerySchema } from './actions/GooglePlacesGetRestaurantRaw';
import { RestaurantInputSchema } from './services/RestaurantInputSchema';

// 定義QueryTime Schema (從Flow 5複製)
const QueryTimeSchema = z.object({
  hour: z.number().min(0).max(23),
  minute: z.number().min(0).max(59)
});

// 定義最終輸出的餐廳結果結構
const RestaurantRecommendationResultSchema = z.object({
  restaurant: RestaurantInputSchema,
  recommendation: RecommendationSchema,
  details: DetailSchema
});

// 定義Flow 8的輸出結構
const RestaurantRecommendationFlowOutputSchema = z.object({
  topThreeRestaurants: z.array(RestaurantRecommendationResultSchema)
});

// 輔助函式：將RestaurantQuerySchema轉換為QuerySchema
const convertRestaurantQueryToQuery = (restaurantQuery: z.infer<typeof RestaurantQuerySchema>): z.infer<typeof QuerySchema> => {
  return {
    minPrice: restaurantQuery.minPrice || 0,
    maxPrice: restaurantQuery.maxPrice || 10000,
    minDistance: restaurantQuery.minDistance || 0,
    maxDistance: restaurantQuery.maxDistance || 5000,
    requirement: restaurantQuery.requirement || "",
    note: restaurantQuery.note || ""
  };
};

// 主要的餐廳推薦Flow - Flow 8
export const restaurantRecommendationFlow = ai.defineFlow(
  {
    name: "restaurantRecommendation",
    inputSchema: z.object({
      restaurantQuery: RestaurantQuerySchema,
      userSetting: UserSettingSchema,
      queryTime: QueryTimeSchema
    }),
    outputSchema: RestaurantRecommendationFlowOutputSchema,
  },
  async (params) => {
    try {
      // Step 1: 使用Flow 5取得所有RestaurantInput
      console.log("Step 1: Getting restaurant raw data and converting to RestaurantInput...");
      const restaurantInputs = await restaurantQueryFlow({
        query: params.restaurantQuery,
        queryTime: params.queryTime
      });

      if (restaurantInputs.length === 0) {
        throw new Error("No restaurants found for the given query");
      }

      // Step 2: 將RestaurantQuerySchema轉換為QuerySchema
      console.log("Step 2: Converting query parameters...");
      const queryParams = convertRestaurantQueryToQuery(params.restaurantQuery);

      // Step 3: 使用Flow 6找到推薦餐廳
      console.log("Step 3: Finding recommended restaurants...");
      const findResult = await findRestaurantsFlow({
        restaurants: restaurantInputs,
        query: queryParams,
        userSetting: params.userSetting
      });

      const { topIndexes, recommendations } = findResult;

      // Step 4: 取得前三家餐廳的詳細資訊\console.log("Step 4: Generating detailed information for top 3 restaurants in parallel...");
      const topThreeCount = Math.min(3, topIndexes.length);

      const topThreeDetailPromises = topIndexes.slice(0, topThreeCount).map(async (index, i) => {
        const restaurant = restaurantInputs[index];
        const recommendation = recommendations[i];

        const details = await detailGenerationFlow({
          restaurant,
          query: queryParams,
          userSetting: params.userSetting,
          previousRecommendation: recommendation
        });

        return {
          restaurant,
          recommendation,
          details
        };
      });

      const topThreeResults = await Promise.all(topThreeDetailPromises);

      return {
        topThreeRestaurants: topThreeResults
      };

    } catch (error) {
      console.error("Error in restaurantRecommendationFlow:", error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new Error(`Restaurant recommendation flow failed: ${errorMessage}`);
    }
  }
);

// 導出相關的Schema供外部使用
export {
  RestaurantRecommendationResultSchema,
  RestaurantRecommendationFlowOutputSchema,
  QueryTimeSchema
};