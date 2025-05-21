import { z } from "genkit";
import { ai } from "../config";
import { gemini20Flash } from "@genkit-ai/vertexai";

// 定義 RestaurantInput schema
const RestaurantInputSchema = z.object({
    distance: z.number(),
    opening: z.boolean(),
    rating: z.number(),
    reviews: z.array(z.object({
        rating: z.number(),
        time: z.string(),
        text: z.string()
    })),
    photoImformation: z.string(),
    name: z.string(),
    summary: z.string(),
    types: z.string(),
    priceInformation: z.string(),
    extraInformation: z.string(),
});

// 定義使用者查詢參數
const QuerySchema = z.object({
    minPrice: z.number(),
    maxPrice: z.number(),
    minDistance: z.number(),
    maxDistance: z.number(),
    requirement: z.string(), // 使用者想吃什麼
    note: z.string(), // 額外備註
});

// 定義使用者設定
const UserSettingSchema = z.object({
    sortedPreference: z.array(z.string()), // 排序偏好，第0個為最高排序優先度
});

// 定義推薦理由的輸出結構
const RecommendationSchema = z.object({
    index: z.number(),
    reason: z.string(),  // 推薦理由
    matchScore: z.number(), // 匹配分數
    matchDetail: z.object({  // 匹配詳情
        price: z.number(),
        distance: z.number(),
        rating: z.number(),
        preference: z.number(),
        requirement: z.number(),
    }),
});

// 修改: 更新DetailSchema，移除價格分析和口味分析，改為偏好分析
const DetailSchema = z.object({
    shortIntroduction: z.string(),  // 推薦理由
    fullIntroduction: z.string(), // 匹配分數
    menu: z.string(),
    reviews: z.string(),
    preferenceAnalysis: z.record(z.string()), // 根據每個偏好進行的分析，key為偏好名稱，value為分析內容
});

// 輔助函式：將排序偏好陣列轉換為字串
const convertPreferenceArrayToString = (preferences: string[]): string => {
    return preferences.join(', ');
};

// 修改: 更新prompt以根據sortedPreference生成分析內容而非固定的價格和口味分析
const detailGenerator = ai.definePrompt({
    model: gemini20Flash,
    name: 'detailGenerator',
    messages: `
    你是一個專業的餐廳介紹員，負責生成詳細、客觀的餐廳介紹。
    請根據以下提供的餐廳資訊、使用者查詢條件和推薦理由，生成詳細的餐廳介紹。

餐廳資訊：
- 名稱：{{restaurantName}}
- 類型：{{restaurantTypes}}
- 評分：{{restaurantRating}}
- 距離：{{restaurantDistance}}公尺
- 是否營業：{{restaurantOpening}}
- 價格資訊：{{restaurantPriceInfo}}
- 照片資訊：{{restaurantPhotoInfo}}
- 摘要：{{restaurantSummary}}
- 額外資訊：{{restaurantExtraInfo}}

使用者查詢：
- 最低價格：{{queryMinPrice}}元
- 最高價格：{{queryMaxPrice}}元
- 最短距離：{{queryMinDistance}}公尺
- 最遠距離：{{queryMaxDistance}}公尺
- 需求：{{queryRequirement}}
- 備註：{{queryNote}}

使用者偏好：
- 排序優先順序（優先項目在前）：{{preferenceString}}

推薦理由：
{{recommendationReason}}

匹配分數：{{recommendationMatchScore}}
匹配詳情：
- 價格匹配度：{{matchDetailPrice}}
- 距離匹配度：{{matchDetailDistance}}
- 評分匹配度：{{matchDetailRating}}
- 偏好匹配度：{{matchDetailPreference}}
- 需求匹配度：{{matchDetailRequirement}}

請嚴格按以下格式提供餐廳詳細資訊：

短介紹：[簡短二十字內概述該餐廳的特色和為何推薦給使用者]
完整介紹：[詳細描述餐廳的氛圍、特色和整體體驗]
菜單推薦：[根據使用者喜好推薦幾道特色菜品，並在條件允許下列出詳細菜單價格]
評論摘要：[摘要顧客評論的重點和共識，主要分優點跟缺點兩個類別整理]

{{#each preferences}}
{{this}}分析：[分析餐廳在{{this}}方面如何符合使用者需求，提供具體例子]
{{/each}}

請使用中文回覆，並保持專業、客觀的語氣。
`,
    input: {
        schema: z.object({
            restaurantName: z.string(),
            restaurantTypes: z.string(),
            restaurantRating: z.number(),
            restaurantDistance: z.number(),
            restaurantOpening: z.string(),
            restaurantPriceInfo: z.string(),
            restaurantPhotoInfo: z.string(),
            restaurantSummary: z.string(),
            restaurantExtraInfo: z.string(),
            queryMinPrice: z.number(),
            queryMaxPrice: z.number(),
            queryMinDistance: z.number(),
            queryMaxDistance: z.number(),
            queryRequirement: z.string(),
            queryNote: z.string(),
            preferenceString: z.string(),
            preferences: z.array(z.string()), // 新增: 用於遍歷的偏好陣列
            recommendationReason: z.string(),
            recommendationMatchScore: z.number(),
            matchDetailPrice: z.number(),
            matchDetailDistance: z.number(),
            matchDetailRating: z.number(),
            matchDetailPreference: z.number(),
            matchDetailRequirement: z.number()
        })
    }
});

// 修改: 更新實現流程，處理動態偏好分析
export const detailGenerationFlow = ai.defineFlow(
    {
        name: "detailGeneration",
        inputSchema: z.object({
            restaurant: RestaurantInputSchema,
            query: QuerySchema,
            userSetting: UserSettingSchema,
            previousRecommendation: RecommendationSchema
        }),
        outputSchema: DetailSchema,
    },
    async (input: any) => {
        try {
            // 打印輸入數據，以便調試
            console.log("輸入數據:", {
                restaurantName: input.restaurant.name,
                queryRequirement: input.query.requirement,
                recommendationReason: input.previousRecommendation.reason,
                sortedPreference: input.userSetting.sortedPreference
            });

            // 獲取偏好陣列
            const preferences = input.userSetting.sortedPreference;
            // 將排序偏好陣列轉換為字串
            const preferenceString = convertPreferenceArrayToString(preferences);
            console.log("轉換後的偏好字串:", preferenceString);
            console.log("偏好陣列:", preferences);

            // 使用detailGenerator生成詳細介紹，但需要展平所有屬性
            const detailResponse = await detailGenerator({
                // 將嵌套結構展平為單一層級的屬性，符合修改後的 schema
                restaurantName: input.restaurant.name,
                restaurantTypes: input.restaurant.types,
                restaurantRating: input.restaurant.rating,
                restaurantDistance: input.restaurant.distance,
                restaurantOpening: input.restaurant.opening ? '是' : '否',
                restaurantPriceInfo: input.restaurant.priceInformation,
                restaurantPhotoInfo: input.restaurant.photoImformation,
                restaurantSummary: input.restaurant.summary,
                restaurantExtraInfo: input.restaurant.extraInformation,
                queryMinPrice: input.query.minPrice,
                queryMaxPrice: input.query.maxPrice,
                queryMinDistance: input.query.minDistance,
                queryMaxDistance: input.query.maxDistance,
                queryRequirement: input.query.requirement,
                queryNote: input.query.note,
                preferenceString: preferenceString,
                preferences: preferences, // 新增: 傳遞偏好陣列
                recommendationReason: input.previousRecommendation.reason,
                recommendationMatchScore: input.previousRecommendation.matchScore,
                matchDetailPrice: input.previousRecommendation.matchDetail.price,
                matchDetailDistance: input.previousRecommendation.matchDetail.distance,
                matchDetailRating: input.previousRecommendation.matchDetail.rating,
                matchDetailPreference: input.previousRecommendation.matchDetail.preference,
                matchDetailRequirement: input.previousRecommendation.matchDetail.requirement
            });

            console.log("Raw response:", detailResponse);

            // 從回應中提取所需信息
            // 根據日誌輸出，正確的路徑應該是通過message.content來獲取文本
            let detailContent = "";

            // 檢查回應結構並安全地提取文本內容
            if (detailResponse && detailResponse.message && detailResponse.message.content) {
                // 因為content是一個陣列含有物件，需要取出實際的文本
                if (Array.isArray(detailResponse.message.content) && detailResponse.message.content.length > 0) {
                    const contentObj = detailResponse.message.content[0];
                    if (contentObj && contentObj.text) {
                        detailContent = contentObj.text;
                    } else if (typeof contentObj === 'string') {
                        detailContent = contentObj;
                    }
                } else if (typeof detailResponse.message.content === 'string') {
                    // 有時API可能直接返回字串而非陣列
                    detailContent = detailResponse.message.content;
                }
            } else if (detailResponse && typeof detailResponse.text === 'string') {
                // 嘗試其他可能的路徑
                detailContent = detailResponse.text;
            } else if (detailResponse && typeof detailResponse === 'string') {
                // 如果整個回應就是一個字串
                detailContent = detailResponse;
            }

            console.log("提取的文本內容:", detailContent);

            // 檢查AI是否回應了預期格式
            if (!detailContent || detailContent.includes("請提供餐廳資訊") || detailContent.length < 50) {
                console.log("AI回應不符合預期，使用備用方案");

                // 使用備用方案：從餐廳和推薦資訊中直接生成
                const restaurant = input.restaurant;
                //const recommendation = input.previousRecommendation;
                
                // 創建偏好分析的備用內容
                const preferenceAnalysis: Record<string, string> = {};
                preferences.forEach(pref => {
                    preferenceAnalysis[pref] = `這家餐廳在${pref}方面表現良好，值得考慮。`;
                });

                return {
                    shortIntroduction: `${restaurant.name}是一家${restaurant.types}，距離您${restaurant.distance}公里，評分為${restaurant.rating}分。`,
                    fullIntroduction: `${restaurant.name}提供優質的${restaurant.types}美食體驗。${restaurant.summary}`,
                    menu: `根據餐廳資訊${restaurant.photoImformation}，推薦您嘗試該餐廳的特色菜品。`,
                    reviews: `根據顧客評論，大多數人對這家餐廳的評價是${restaurant.reviews.length > 0 ? restaurant.reviews[0].text : '正面的'}。`,
                    preferenceAnalysis: preferenceAnalysis
                };
            }

            // 解析AI生成的內容，提取各部分
            const shortIntroduction = cleanExtractedContent(extractSection("短介紹", detailContent) || "未能生成短介紹");
            const fullIntroduction = cleanExtractedContent(extractSection("完整介紹", detailContent) || "未能生成完整介紹");
            const menu = cleanExtractedContent(extractSection("菜單推薦", detailContent) || "未能生成菜單推薦");
            const reviews = cleanExtractedContent(extractSection("評論摘要", detailContent) || "未能生成評論摘要");
            
            // 提取每個偏好的分析
            const preferenceAnalysis: Record<string, string> = {};
            preferences.forEach(pref => {
                const analysisContent = cleanExtractedContent(extractSection(`${pref}分析`, detailContent));
                preferenceAnalysis[pref] = analysisContent || `未能生成${pref}分析`;
            });

            // 構建輸出對象
            const result = {
                shortIntroduction,
                fullIntroduction,
                menu,
                reviews,
                preferenceAnalysis
            };

            // 打印更多偵錯信息
            console.log("解析結果:");
            console.log("短介紹:", shortIntroduction);
            console.log("完整介紹:", fullIntroduction);
            console.log("菜單推薦:", menu);
            console.log("評論摘要:", reviews);
            console.log("偏好分析:", preferenceAnalysis);

            console.log("生成的詳細資訊:", result);
            return result;
        } catch (error) {
            console.error("詳細餐廳資訊生成失敗:", error);
            // 返回基本的錯誤信息
            const errorResult = {
                shortIntroduction: "生成詳細資訊時發生錯誤",
                fullIntroduction: "無法提供完整介紹",
                menu: "無法提供菜單推薦",
                reviews: "無法提供評論摘要",
                preferenceAnalysis: {}
            };
            
            // 為每個偏好創建錯誤信息
            input.userSetting.sortedPreference.forEach((pref: string) => {
                (errorResult.preferenceAnalysis as Record<string, string>)[pref] = `無法提供${pref}分析`;
            });
            
            console.log("發生錯誤，返回預設值:", errorResult);
            return errorResult;
        }
    }
);

// 更新sections以包含"分析"模式的標題
// 注意: 動態偏好分析會在運行時處理，這裡不再需要固定的sections列表
//const baseSections = ["短介紹", "完整介紹", "菜單推薦", "評論摘要"];

function extractSection(sectionName: string, content: string): string {
    // 創建動態的正則表達式來匹配目標部分
    const patterns = [
        // 基本匹配：尋找標題後的內容，直到下一個標題或文檔結束
        new RegExp(`\\*\\*${sectionName}[：:](.*?)(?=\\n\\*\\*|$)`, 's'),
        // 匹配標記後的部分直到下一個部分開始
        new RegExp(`\\*\\*${sectionName}[：:]\\*\\*\\s*(.*?)(?=\\n\\*\\*|$)`, 's'),
        // 簡單的部分標題後匹配內容
        new RegExp(`${sectionName}[：:](.*?)(?=\\n(?:\\*\\*|[^\\s])|$)`, 's')
    ];

    // 嘗試每個模式直到找到匹配
    for (const pattern of patterns) {
        const match = content.match(pattern);
        if (match && match[1]) {
            return match[1].trim();
        }
    }

    // 當我們無法使用簡單模式找到時，嘗試尋找部分之間的內容
    // 首先，找到當前部分的位置
    const currentHeaderRegex = new RegExp(`${sectionName}[：:]`, 'i');
    const currentMatch = content.match(currentHeaderRegex);
    
    if (currentMatch && currentMatch.index !== undefined) {
        const startPos = currentMatch.index + currentMatch[0].length;
        
        // 創建一個可能下一個部分的正則表達式
        // 這將匹配任何文本後面跟著冒號，這通常表示一個新的部分標題
        const nextSectionRegex = /\n\s*[\w\u4e00-\u9fa5]+[：:]/;
        const nextMatch = content.slice(startPos).match(nextSectionRegex);
        
        if (nextMatch && nextMatch.index !== undefined) {
            return content.slice(startPos, startPos + nextMatch.index).trim();
        } else {
            // 如果沒有找到下一個部分，返回從當前部分到結束的所有內容
            return content.slice(startPos).trim();
        }
    }

    return `未能提取${sectionName}部分`;
}

// 清理提取的內容 - 移除多餘的標記和格式化
function cleanExtractedContent(content: string): string {
    if (!content) return "";
    
    // 移除開頭的星號和其他可能的標記
    let cleaned = content.replace(/^\*+\s*/, "");
    
    // 移除多餘的空行
    cleaned = cleaned.replace(/\n{3,}/g, "\n\n");
    
    // 移除 markdown 列表標記前的額外空格
    cleaned = cleaned.replace(/\n\s+\*/g, "\n*");
    
    return cleaned.trim();
}