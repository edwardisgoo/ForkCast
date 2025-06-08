import { z } from "genkit";
import { ai } from "../config";
import { RestaurantInputSchema } from './RestaurantInputSchema'; // Flow 5
import { UserSettingSchema, RecommendationSchema } from './findRestaurants'; // Flow 6
import { DetailSchema } from './detailGeneration'; // Flow 7
import { RestaurantQuerySchema } from './actions/GooglePlacesGetRestaurantRaw';

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

// Hard-coded 測試資料 (參考範例輸出格式)
const generateMockRestaurantData = () => {
  // 模擬餐廳基本資料 (符合範例格式)
  const mockRestaurants = [
    {
      id:"aaaaaa",
      distance: 85.5,
      opening: true,
      rating: 4.3,
      reviews: [
        {
          rating: 5,
          time: "2025-05-10T14:30:00.000Z",
          text: "這家義式餐廳真的很棒！手工義大利麵口感Q彈，醬汁濃郁不膩。老闆很用心在做料理，每次來都有驚喜。環境舒適，很適合約會或家庭聚餐。價格合理，CP值很高，推薦給喜歡義式料理的朋友！"
        },
        {
          rating: 4,
          time: "2025-05-08T19:45:00.000Z",
          text: "餐點品質穩定，服務態度良好。瑪格麗特披薩的餅皮很香，海鮮義大利麵料很豐富。唯一小缺點是用餐時間人比較多，需要等位。整體來說是值得回訪的餐廳。"
        },
        {
          rating: 5,
          time: "2025-04-28T12:15:00.000Z",
          text: "第一次來用餐就被驚艷到！松露野菇燉飯香氣撲鼻，每一口都能感受到食材的新鮮。店員很親切，會介紹招牌菜。停車也方便，下次還會再來！"
        }
      ],
      photoInformation: "共 8 張照片，成功辨識 2 張菜單圖片。菜單內容：手工義大利麵 $180-$220、瑪格麗特披薩 $280、海鮮義大利麵 $250、松露野菇燉飯 $320、提拉米蘇 $120",
      name: "托斯卡納義式餐廳",
      summary: "",
      types: "餐廳",
      priceInformation: "中等",
      extraInformation: "外送 / 內用 / 可預約 / 提供紅酒 / 外帶",
      openingHours:[],
    },
    {
      id:"bbbbbb",
      distance: 120.8,
      opening: true,
      rating: 4.1,
      reviews: [
        {
          rating: 4,
          time: "2025-05-12T18:20:00.000Z",
          text: "日式定食很豐富，生魚片新鮮，味噌湯也很濃郁。環境乾淨整潔，有日式的氛圍。服務人員很有禮貌，上餐速度適中。價格算合理，適合想吃日式料理的時候來。"
        },
        {
          rating: 5,
          time: "2025-05-09T13:10:00.000Z",
          text: "照燒雞腿排超讚！肉質嫩而且調味剛好，搭配的蔬菜也很新鮮。壽司師傅的手藝很好，每貫壽司都很精緻。茶碗蒸也做得很好，整體用餐體驗很滿意。"
        },
        {
          rating: 3,
          time: "2025-04-30T20:05:00.000Z",
          text: "餐點還可以，但沒有特別驚艷。拉麵湯頭偏淡，可能比較適合口味清淡的人。服務OK，環境也乾淨，但整體CP值普通。"
        }
      ],
      photoInformation: "共 6 張照片，成功辨識 1 張菜單圖片。菜單內容：照燒雞腿排定食 $280、綜合生魚片 $320、握壽司套餐 $380、味噌拉麵 $180、茶碗蒸 $80",
      name: "櫻花日式料理",
      summary: "",
      types: "餐廳",
      priceInformation: "中等",
      extraInformation: "外送 / 內用 / 外帶 / 提供清酒",
      openingHours:[],
    },
    {
      id:"cccccc",
      distance: 180.3,
      opening: true,
      rating: 4.5,
      reviews: [
        {
          rating: 5,
          time: "2025-05-11T21:30:00.000Z",
          text: "牛排品質真的很棒！點了肋眼牛排，熟度掌握得很好，外酥內嫩。配菜的蒜蓉麵包和沙拉也很用心。服務生很專業，會詢問用餐需求和喜好。雖然價格偏高，但物有所值！"
        },
        {
          rating: 4,
          time: "2025-05-07T19:15:00.000Z",
          text: "環境很有質感，適合慶祝或商務聚餐。菲力牛排很嫩，醬汁搭配得很好。紅酒選擇也不錯，服務人員會推薦搭配。唯一就是價位比較高，偶爾來享受一下還不錯。"
        },
        {
          rating: 5,
          time: "2025-04-25T20:45:00.000Z",
          text: "慶祝結婚週年來的，從預約到用餐都很滿意。牛排烤得恰到好處，龍蝦也很新鮮。還有提供生日驚喜服務，讓這個夜晚更加特別。雖然花費不少，但值得！"
        }
      ],
      photoInformation: "共 12 張照片，成功辨識 3 張菜單圖片。菜單內容：美國Prime肋眼牛排 $880、澳洲和牛菲力 $1200、龍蝦尾配牛排 $1580、前菜拼盤 $380、紅酒 $200-$800/杯",
      name: "極上牛排館",
      summary: "",
      types: "餐廳",
      priceInformation: "高等",
      extraInformation: "內用 / 可預約 / 提供紅酒 / 代客泊車 / 包廂服務",
      openingHours:[],
    }
  ];

  // 模擬推薦資料 (符合範例格式)
  const mockRecommendations = [
    {
      index: 0,
      reason: "托斯卡納義式餐廳價格中等，符合使用者預算。距離使用者很近，且評價不錯。義式料理通常較少辣味，可以避開辣味需求。從評論來看，手工義大利麵、披薩等都是不錯的選擇，且有多樣不辣的餐點選擇。",
      matchScore: 0.95,
      matchDetail: {
        price: 1,
        distance: 0.98,
        rating: 0.9,
        preference: 0.95,
        requirement: 0.95
      }
    },
    {
      index: 1,
      reason: "櫻花日式料理價格中等，符合使用者預算。距離適中，評價普通但可接受。日式料理通常口味清淡較少辣味，適合不吃辣的需求。定食和壽司等選擇多樣，可以找到合適的餐點。",
      matchScore: 0.88,
      matchDetail: {
        price: 1,
        distance: 0.85,
        rating: 0.82,
        preference: 0.9,
        requirement: 0.9
      }
    },
    {
      index: 2,
      reason: "極上牛排館雖然價格偏高，但品質優秀，評價很好。距離稍遠但仍在可接受範圍。牛排料理通常不辣，符合使用者需求。雖然超出預算但如果想要高品質用餐體驗，是不錯的選擇。",
      matchScore: 0.75,
      matchDetail: {
        price: 0.3,
        distance: 0.8,
        rating: 0.95,
        preference: 0.85,
        requirement: 0.95
      }
    }
  ];

  // 模擬詳細資訊 (符合範例格式)
  const mockDetails = [
    {
      shortIntroduction: "托斯卡納義式餐廳近在咫尺，價格親民，正宗義式料理不辣，滿足您的需求！",
      fullIntroduction: "托斯卡納義式餐廳提供舒適的內用環境，也支持外送和外帶，方便快捷。作為一家義式餐廳，它提供多樣化的餐點選擇，手工義大利麵、披薩、燉飯等都是熱門選項。餐廳的評價不錯，4.3分表明它在口味和服務上都有一定的水準。特別是對於不喜辣的使用者，義式料理通常較為溫和，能讓您放心享用美食。餐廳也提供紅酒，適合與朋友小酌。可預約服務讓您不必擔心排隊等候。",
      menu: "推薦菜品：\n• 手工義大利麵：新鮮製作，口感Q彈，價格$180-$220\n• 瑪格麗特披薩：經典口味，餅皮香酥，價格$280\n• 松露野菇燉飯：香氣撲鼻，食材新鮮，價格$320\n• 提拉米蘇：經典甜點，完美結尾，價格$120\n\n備註：所有餐點價格都在使用者預算範圍內，可放心選擇。",
      reviews: "優點：\n• 價格合理，性價比高\n• 手工製作，品質穩定\n• 環境舒適，適合聚餐\n• 服務態度良好\n\n缺點：\n• 用餐高峰期可能需要等位\n• 停車位有限",
      preferenceAnalysis: {
        "價格": "托斯卡納義式餐廳的價格定位在中等，從菜單來看，大多數餐點的價格都在300元以內，符合您設定的價格限制。例如，手工義大利麵$180-$220，瑪格麗特披薩$280，都在您的預算範圍內。",
        "特殊需求": "您不希望吃辣，而義式料理通常以番茄、橄欖油、香草為基調，很少使用辣椒。托斯卡納義式餐廳的菜單上，如義大利麵、披薩、燉飯等，都沒有辣味，可以放心選擇。",
        "人潮": "餐廳評分4.3分，從評論看來生意不錯，用餐高峰期可能會有等位情況。建議提前預約，或避開12:00-13:00及18:00-19:00的用餐尖峰時段。",
        "距離": "托斯卡納義式餐廳距離您只有85.5公尺，遠小於您設定的300公尺最遠距離限制，步行即可輕鬆到達，非常方便。"
      }
    },
    {
      shortIntroduction: "櫻花日式料理距離適中，價格中等，清淡日式口味不辣，符合您的用餐需求。",
      fullIntroduction: "櫻花日式料理是一家提供傳統日式餐點的餐廳，環境乾淨整潔，營造出濃厚的日式氛圍。餐廳提供多樣化的日式料理，包括定食、壽司、拉麵等。雖然評分為4.1，但整體用餐體驗還是不錯的。日式料理以清淡口味著稱，很適合不喜歡吃辣的顧客。餐廳支援外送、內用和外帶服務，用餐方式靈活多樣。",
      menu: "推薦菜品：\n• 照燒雞腿排定食：肉質嫩滑，調味適中，價格$280\n• 綜合生魚片：新鮮海鮮，刀工精細，價格$320\n• 握壽司套餐：師傅手藝精湛，種類豐富，價格$380\n• 味噌拉麵：湯頭清香，配料豐富，價格$180\n\n備註：所有餐點都在預算範圍內，口味清淡不辣。",
      reviews: "優點：\n• 環境乾淨，日式氛圍濃厚\n• 食材新鮮，製作用心\n• 服務人員有禮貌\n• 價格合理\n\n缺點：\n• 部分餐點口味偏淡\n• 整體CP值普通",
      preferenceAnalysis: {
        "價格": "櫻花日式料理的餐點價格在$80-$380之間，大部分都在您的300元預算範圍內。像是味噌拉麵$180、照燒雞腿排定食$280等，都是經濟實惠的選擇。",
        "特殊需求": "日式料理以清淡口味為主，很少使用辣椒調味。櫻花日式料理的菜單上，包括壽司、定食、拉麵等，都是不辣的選擇，完全符合您不吃辣的需求。",
        "人潮": "餐廳評分4.1分，生意還算不錯。從評論看來用餐環境舒適，但建議避開用餐尖峰時段，以免需要等位。",
        "距離": "櫻花日式料理距離您120.8公尺，在您設定的300公尺範圍內，步行約2-3分鐘即可到達，距離適中且方便。"
      }
    },
    {
      shortIntroduction: "極上牛排館品質頂級，環境優雅，牛排料理不辣，但價格較高，適合特殊場合。",
      fullIntroduction: "極上牛排館是一家高級牛排餐廳，以優質的牛肉和精緻的用餐環境著稱。餐廳評分高達4.5分，顯示其在食材品質和服務水準上都有優異表現。雖然價格偏高，但提供的是頂級的用餐體驗。餐廳提供多種進口牛肉選擇，烹調技術專業，適合慶祝特殊場合或商務聚餐。牛排料理基本不含辣味，符合您的飲食需求。",
      menu: "推薦菜品：\n• 美國Prime肋眼牛排：品質頂級，口感絕佳，價格$880\n• 澳洲和牛菲力：入口即化，極致享受，價格$1200\n• 龍蝦尾配牛排：海陸雙拼，奢華體驗，價格$1580\n• 前菜拼盤：精緻開胃，品味多樣，價格$380\n\n備註：價格較高，超出您的預算範圍，但品質卓越。",
      reviews: "優點：\n• 牛肉品質頂級，烹調技術專業\n• 環境優雅，適合特殊場合\n• 服務專業，細致入微\n• 提供包廂和代客泊車服務\n\n缺點：\n• 價格昂貴，超出一般預算\n• 需要提前預約",
      preferenceAnalysis: {
        "價格": "極上牛排館的價格明顯超出您設定的300元預算，主餐價格從$880起跳，最高達$1580。雖然品質優秀，但不符合您的價格需求，建議考慮其他選擇。",
        "特殊需求": "牛排料理基本上都不含辣味，調味主要以鹽、胡椒、香草為主，完全符合您不吃辣的需求。可以放心享用各種牛排料理。",
        "人潮": "作為高級餐廳，極上牛排館通常需要提前預約。評分4.5分顯示其受歡迎程度很高，建議提前致電預約，以確保有位子。",
        "距離": "極上牛排館距離您180.3公尺，在300公尺的可接受範圍內，步行約3-4分鐘可到達，距離還算可以接受。"
      }
    }
  ];

  return mockRestaurants.map((restaurant, index) => ({
    restaurant,
    recommendation: mockRecommendations[index],
    details: mockDetails[index]
  }));
};

// 測試用的餐廳推薦Flow - Mock Flow 8
export const restaurantRecommendationFlowMock = ai.defineFlow(
  {
    name: "restaurantRecommendationMock",
    inputSchema: z.object({
      restaurantQuery: RestaurantQuerySchema,
      userSetting: UserSettingSchema,
      queryTime: QueryTimeSchema
    }),
    outputSchema: RestaurantRecommendationFlowOutputSchema,
  },
  async (params) => {
    try {
      console.log("Mock Flow: Generating hard-coded restaurant recommendations...");
      console.log("Input params:", {
        query: params.restaurantQuery,
        userSetting: params.userSetting,
        queryTime: params.queryTime
      });

      // 模擬處理時間 (可選)
      await new Promise(resolve => setTimeout(resolve, 1000));

      // 生成模擬資料
      const mockData = generateMockRestaurantData();

      console.log("Mock Flow: Returning 3 hard-coded restaurant recommendations");

      return {
        topThreeRestaurants: mockData
      };

    } catch (error) {
      console.error("Error in restaurantRecommendationFlowMock:", error);
      const errorMessage = error instanceof Error ? error.message : String(error);
      throw new Error(`Mock restaurant recommendation flow failed: ${errorMessage}`);
    }
  }
);

// 導出相關的Schema供外部使用
export {
  RestaurantRecommendationResultSchema,
  RestaurantRecommendationFlowOutputSchema,
  QueryTimeSchema
};