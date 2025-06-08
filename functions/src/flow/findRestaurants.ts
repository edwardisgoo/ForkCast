import { z } from "genkit";
import { ai } from "../config";
import { gemini20Flash } from "@genkit-ai/vertexai";
import { RestaurantInputSchema } from './RestaurantInputSchema';



// 定義使用者查詢參數
export const QuerySchema = z.object({
    minPrice: z.number(),
    maxPrice: z.number(),
    minDistance: z.number(),
    maxDistance: z.number(),
    requirement: z.string(), // 使用者想吃什麼
    note: z.string(), // 額外備註
});

// 定義使用者設定
export const UserSettingSchema = z.object({
    sortedPreference: z.array(z.string()), // 排序偏好，第0個為最高排序優先度
});

// 定義推薦理由的輸出結構
export const RecommendationSchema = z.object({
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

// 增強版實現 - 加入使用者偏好
export const findRestaurantsFlow = ai.defineFlow(
    {
        name: "findRestaurants",
        inputSchema: z.object({
            restaurants: z.array(RestaurantInputSchema),
            query: QuerySchema,
            userSetting: UserSettingSchema
        }),
        outputSchema: z.object({
            topIndexes: z.array(z.number()),
            recommendations: z.array(RecommendationSchema)
        })
    },
    async (input: { restaurants: any[]; query: { maxPrice: number; minPrice: number; minDistance: number; maxDistance: number; requirement: any; note: any; }; userSetting: { sortedPreference: any[]; }; }) => {
        try {
            console.log("開始尋找合適餐廳(findRestaurants)")
            console.log("Processing restaurants:", input.restaurants.length);
            console.log("User query:", input.query);
            console.log("User settings:", input.userSetting);

            // 簡單的價格解析函數 - 從字串中提取價格範圍
            function extractPriceRange(priceInfo: string) {
                // 假設 priceInformation 格式如 "$$ (100-300元)" 或類似
                const priceLevel = (priceInfo.match(/\$+/) || ["$$"])[0].length;

                // 嘗試提取數字範圍
                const numbers = priceInfo.match(/\d+/g);
                let minPrice = 0;
                let maxPrice = 1000;  // 預設最高價格

                if (numbers && numbers.length >= 2) {
                    minPrice = parseInt(numbers[0]);
                    maxPrice = parseInt(numbers[1]);
                } else if (priceLevel === 1) {
                    minPrice = 0;
                    maxPrice = 100;
                } else if (priceLevel === 2) {
                    minPrice = 100;
                    maxPrice = 300;
                } else if (priceLevel === 3) {
                    minPrice = 300;
                    maxPrice = 600;
                } else if (priceLevel >= 4) {
                    minPrice = 600;
                    maxPrice = 2000;
                }

                return { minPrice, maxPrice };
            }

            // 預處理 - 先篩選符合基本條件的餐廳
            const eligibleRestaurants = input.restaurants
                .map((restaurant: { priceInformation: any; distance: number; rating: number; }, index: any) => {
                    // 解析價格資訊
                    const { minPrice, maxPrice } = extractPriceRange(restaurant.priceInformation);

                    // 檢查價格和距離條件
                    const withinPriceRange =
                        (minPrice <= input.query.maxPrice && maxPrice >= input.query.minPrice);

                    const withinDistanceRange =
                        (restaurant.distance >= input.query.minDistance &&
                            restaurant.distance <= input.query.maxDistance);

                    // 計算初步匹配分數
                    const matchDetail = {
                        price: withinPriceRange ? 1 : 0,
                        distance: withinDistanceRange ? 1 : 0,
                        rating: restaurant.rating / 5,  // 標準化評分
                        preference: 0,  // 稍後根據使用者偏好計算
                        requirement: 0, // 稍後根據使用者需求計算
                    };

                    return {
                        index,
                        restaurant,
                        eligible: true,//withinPriceRange && withinDistanceRange,
                        priceRange: { minPrice, maxPrice },
                        matchDetail
                    };
                })
                .filter((item: { eligible: any; }) => item.eligible);

            console.log("Eligible restaurants after filtering:", eligibleRestaurants.length);

            // 如果沒有符合條件的餐廳，擴大搜索範圍
            if (eligibleRestaurants.length < 3) {
                console.log("擴大搜索範圍...");
                return await fallbackStrategy(input);
            }
            
            // 構建提示以加入使用者偏好
            const prompt = `你是一位美食推薦專家。根據使用者的偏好和需求，從以下餐廳中選出最適合的三家推薦。

使用者查詢:
價格範圍: ${input.query.minPrice} 到 ${input.query.maxPrice} 元
距離範圍: ${input.query.minDistance} 到 ${input.query.maxDistance} 公尺
特定需求: ${input.query.requirement}
備註: ${input.query.note}

使用者偏好排序 (從高到低):
${input.userSetting.sortedPreference.map((pref: any, i: number) => `${i + 1}. ${pref}`).join('\n')}

以下是餐廳資訊 (已經過初步篩選，符合使用者的基本價格和距離要求):
\`\`\`json
${JSON.stringify(eligibleRestaurants.map((item: { restaurant: any; }) => item.restaurant), null, 2)}
\`\`\`

請根據使用者的偏好排序和特定需求，選擇最適合的三家餐廳。對於每家餐廳，提供詳細的推薦理由，說明它如何符合使用者的各項偏好和需求。

針對每家餐廳，請提供以下資訊:
1. 餐廳在原始列表中的索引 (index)
2. 詳細的推薦理由 (reason)，說明為什麼這家餐廳適合使用者
3. 匹配分數 (匹配度評估，0-1之間)
4. 匹配詳情 (各方面的匹配程度):
   - 價格匹配程度 (0-1)
   - 距離匹配程度 (0-1)
   - 評分匹配程度 (0-1)
   - 與使用者偏好匹配程度 (0-1)
   - 與特定需求匹配程度 (0-1)

請以JSON格式輸出:

{
  "topIndexes": [A, B, C],
  "recommendations": [
    {
      "index": A,
      "reason": "推薦理由...",
      "matchScore": 0.95,
      "matchDetail": {
        "price": 0.9,
        "distance": 1.0,
        "rating": 0.88,
        "preference": 0.95,
        "requirement": 0.85
      }
    },
    {...},
    {...}
  ]
}

其中 A、B、C 是餐廳在原始輸入陣列中的索引。如果餐廳名稱中包含使用者需求的關鍵字或類型中包含相關字詞，請加以重視。`;

            // 直接使用模型生成
            console.log("prompt:",prompt);
            const response = await ai.generate({
                model: gemini20Flash,
                prompt: prompt,
            });

            console.log("Raw response:", response);

            // 提取文本內容
            let text = extractTextFromResponse(response);
            console.log("Extracted text:", text);

            // 解析 JSON
            const parsed = parseJsonFromText(text);

            // 後處理結果
            const result = postProcessResults(parsed, input.restaurants);

            console.log("Final topIndexes:", result.topIndexes);
            console.log("Final recommendations:", result.recommendations);

            return result;

        } catch (err) {
            console.error("處理過程中出錯:", err);
            return await fallbackStrategy(input);
        }
    }
);

// 提取文本內容
function extractTextFromResponse(response: any) {
    let text = "";
    if (typeof response === "string") {
        text = response;
    } else if (response?.text) {
        text = response.text;
    } else if (response?.content) {
        text = typeof response.content === "string"
            ? response.content
            : JSON.stringify(response.content);
    } else {
        // 嘗試從各種可能的位置獲取文本
        const possibleTextLocations = [
            response?.message?.content,
            response?.message?.text,
            response?.parts?.[0]?.text,
            response?.candidates?.[0]?.content?.parts?.[0]?.text
        ];

        for (const loc of possibleTextLocations) {
            if (loc && typeof loc === "string") {
                text = loc;
                break;
            }
        }

        if (!text) {
            console.error("無法從響應中提取文本:", response);
            throw new Error("無法從模型響應中提取文本");
        }
    }
    return text;
}

// 解析 JSON
/*function parseJsonFromText(text: string) {
    const jsonRegex = /\{[\s\S]*?\}/g;
    const jsonMatches = text.match(jsonRegex);

    if (!jsonMatches || jsonMatches.length === 0) {
        throw new Error("從模型回應中找不到 JSON 格式");
    }

    // 嘗試解析可能是完整 JSON 的字符串
    let completeJson = text.match(/\{[\s\S]*\}/);
    let parsed = null;

    if (completeJson) {
        try {
            const candidate = JSON.parse(completeJson[0]);
            if (candidate && candidate.topIndexes && Array.isArray(candidate.topIndexes)) {
                console.log("成功解析完整 JSON");
                parsed = candidate;
            }
        } catch (err) {
            console.log("解析完整 JSON 失敗，將嘗試解析各個 JSON 塊");
        }
    }

    // 如果完整解析失敗，嘗試解析每個匹配的 JSON 字符串
    let parseError: Error | null = null;

    if (!parsed) {
        for (const jsonStr of jsonMatches) {
            try {
                const candidate = JSON.parse(jsonStr);
                if (candidate && candidate.topIndexes && Array.isArray(candidate.topIndexes)) {
                    parsed = candidate;
                    break;
                }
            } catch (err) {
                parseError = err instanceof Error ? err : new Error(String(err));
                console.log("解析 JSON 失敗:", jsonStr, err);
            }
        }
    }

    if (!parsed) {
        throw new Error("無法解析有效的 JSON 格式: " + (parseError ? parseError.message : "未知錯誤"));
    }

    return parsed;
}*/

// 定義明確的介面類型
interface MatchDetail {
    price: number;
    distance: number;
    rating: number;
    preference: number;
    requirement: number;
}

interface Recommendation {
    index: number;
    reason: string;
    matchScore: number;
    matchDetail: MatchDetail;
}

interface ParsedResult {
    topIndexes: number[];
    recommendations: Recommendation[];
}

// 改進的 JSON 解析函數
function parseJsonFromText(text: string): ParsedResult {
    console.log("Attempting to parse JSON from text:", text);
    
    // 1. 清理文本，移除可能的錯誤訊息
    text = text.replace(/SyntaxError:[\s\S]*$/, '');
    
    // 2. 嘗試找到最完整的 JSON 結構
    let jsonMatches;
    
    // 先尋找完整的大括號對
    const completeJsonRegex = /\{[\s\S]*?\}/g;
    jsonMatches = text.match(completeJsonRegex);
    
    if (!jsonMatches || jsonMatches.length === 0) {
        throw new Error("從模型回應中找不到 JSON 格式");
    }
    
    // 3. 嘗試解析每個可能的 JSON 字符串
    let parsed: ParsedResult | null = null;
    let parseError: Error | null = null;
    
    // 先嘗試最長的 JSON 字符串，可能性最高
    jsonMatches.sort((a, b) => b.length - a.length);
    
    for (const jsonStr of jsonMatches) {
        try {
            // 處理多行字符串問題
            const fixedJsonStr = jsonStr
                .replace(/\n/g, '\\n') // 替換換行符
                .replace(/\r/g, '\\r') // 替換回車符
                .replace(/\t/g, '\\t') // 替換製表符
                .replace(/\"/g, '\\"') // 轉義雙引號
                .replace(/\\\\/g, '\\') // 修復重複的反斜槓
                .replace(/"{/g, '{')   // 修復異常的開始引號
                .replace(/}"/g, '}')   // 修復異常的結束引號
                .replace(/([^\\])"/g, '$1\\"') // 為未轉義的雙引號添加轉義符
                .replace(/\\\\"/g, '\\"') // 修復可能的過度轉義
                .replace(/(['"])([\s\S]*?)([^\\])\1/g, function(match, quote, content, end) {
                    // 確保字符串內容中所有引號都被正確轉義
                    return quote + content.replace(new RegExp(quote, 'g'), '\\' + quote) + end + quote;
                });
            
            // 檢查括號平衡
            let fixedJson = balanceBrackets(fixedJsonStr);
            
            console.log("Attempting to parse JSON:", fixedJson);
            const candidate = JSON.parse(fixedJson);
            
            // 驗證解析結果
            if (candidate) {
                if (isSingleRecommendation(candidate)) {
                    // 如果只是單個推薦對象，則構建完整的結構
                    console.log("Found single recommendation, building full structure");
                    parsed = {
                        topIndexes: [candidate.index],
                        recommendations: [candidate as Recommendation]
                    };
                    break;
                } else if (candidate.topIndexes && Array.isArray(candidate.topIndexes)) {
                    console.log("成功解析完整 JSON 結構");
                    parsed = candidate as ParsedResult;
                    break;
                } else if (candidate.recommendations && Array.isArray(candidate.recommendations)) {
                    console.log("找到推薦數組，構建完整結構");
                    // 從推薦中提取 topIndexes
                    const indices = candidate.recommendations.map((rec: Recommendation) => rec.index);
                    parsed = {
                        topIndexes: indices,
                        recommendations: candidate.recommendations as Recommendation[]
                    };
                    break;
                }
            }
        } catch (err) {
            parseError = err instanceof Error ? err : new Error(String(err));
            console.log("解析 JSON 失敗:", err);
        }
    }
    
    // 4. 如果單獨解析失敗，嘗試修復和組合 JSON
    if (!parsed) {
        try {
            console.log("嘗試修復和組合 JSON");
            parsed = repairAndCombineJson(text);
        } catch (err) {
            console.log("修復組合失敗:", err);
        }
    }
    
    if (!parsed) {
        throw new Error("無法解析有效的 JSON 格式: " + (parseError ? parseError.message : "未知錯誤"));
    }
    
    return parsed;
}

// 檢查是否為單個推薦對象
function isSingleRecommendation(obj: any): obj is Recommendation {
    return obj && 
           typeof obj.index !== 'undefined' && 
           typeof obj.reason === 'string' &&
           typeof obj.matchScore === 'number' &&
           obj.matchDetail;
}

// 檢查和平衡括號
function balanceBrackets(jsonStr: string): string {
    // 計算開閉括號
    let openBraces = (jsonStr.match(/\{/g) || []).length;
    let closeBraces = (jsonStr.match(/\}/g) || []).length;
    
    // 添加缺失的閉括號
    if (openBraces > closeBraces) {
        jsonStr += '}'.repeat(openBraces - closeBraces);
    }
    
    return jsonStr;
}

// 修復並組合 JSON
function repairAndCombineJson(text: string): ParsedResult {
    // 尋找推薦對象
    const recommendationRegex = /"index"\s*:\s*(\d+)[\s\S]*?"reason"\s*:\s*"([^"]*)"[\s\S]*?"matchScore"\s*:\s*([\d\.]+)[\s\S]*?"matchDetail"\s*:\s*\{[\s\S]*?\}/g;
    const recommendations: Recommendation[] = [];
    const indices: number[] = [];
    let match;
    
    while ((match = recommendationRegex.exec(text)) !== null) {
        try {
            // 提取匹配的文本並嘗試構建 JSON
            const fullMatch = match[0];
            const index = parseInt(match[1]);
            indices.push(index);
            
            // 使用正則表達式提取 matchDetail
            const matchDetailRegex = /"matchDetail"\s*:\s*(\{[\s\S]*?\})/;
            const matchDetailMatch = fullMatch.match(matchDetailRegex);
            let matchDetail: MatchDetail = {
                price: 0.8,
                distance: 0.7,
                rating: 0.7,
                preference: 0.6,
                requirement: 0.5
            };
            
            if (matchDetailMatch && matchDetailMatch[1]) {
                try {
                    // 清理和修復 matchDetail 字符串
                    let detailStr = matchDetailMatch[1]
                        .replace(/([a-zA-Z0-9_]+)\s*:/g, '"$1":') // 確保所有鍵被引號包圍
                        .replace(/,\s*\}/g, '}'); // 移除尾隨逗號
                    
                    const parsedDetail = JSON.parse(balanceBrackets(detailStr));
                    matchDetail = {
                        price: parsedDetail.price || 0.8,
                        distance: parsedDetail.distance || 0.7,
                        rating: parsedDetail.rating || 0.7,
                        preference: parsedDetail.preference || 0.6,
                        requirement: parsedDetail.requirement || 0.5
                    };
                } catch (e) {
                    console.log("無法解析 matchDetail，使用默認值:", e);
                }
            }
            
            recommendations.push({
                index: index,
                reason: match[2].replace(/\n/g, ' '), // 替換換行符為空格
                matchScore: parseFloat(match[3]),
                matchDetail: matchDetail
            });
        } catch (e) {
            console.log("處理推薦對象時出錯:", e);
        }
    }
    
    if (recommendations.length > 0) {
        return {
            topIndexes: indices,
            recommendations: recommendations
        };
    }
    
    throw new Error("無法從文本中提取有效的推薦對象");
}

// 後處理結果
function postProcessResults(parsed: { topIndexes: (number | undefined)[]; recommendations: { index: any; reason: string; matchScore: number; matchDetail: { price: number; distance: number; rating: number; preference: number; requirement: number; } | { price: number; distance: number; rating: number; preference: number; requirement: number; }; }[]; }, restaurants: string | any[]) {
    // 驗證輸出格式
    if (!parsed.topIndexes || !Array.isArray(parsed.topIndexes)) {
        throw new Error("模型回傳的 JSON 不包含 topIndexes 數組");
    }

    // 檢查是否有推薦理由
    if (!parsed.recommendations || !Array.isArray(parsed.recommendations)) {
        console.log("警告: 模型未返回推薦理由，將自動生成");
        parsed.recommendations = [];
    }

    // 驗證索引有效性
    parsed.topIndexes = parsed.topIndexes.filter((idx: unknown): idx is number =>
        Number.isInteger(idx) && typeof idx === 'number' && idx >= 0 && idx < restaurants.length
    );

    // 如果返回少於三個索引，用有效的索引填充
    if (parsed.topIndexes.length < 3) {
        console.log("警告: 模型僅返回了", parsed.topIndexes.length, "個索引，將添加額外索引以達到要求的 3 個");

        // 獲取所有有效的索引
        const allValidIndexes = [...Array(restaurants.length).keys()];
        // 移除已經在 topIndexes 中的索引
        const remainingIndexes = allValidIndexes.filter(idx => !parsed.topIndexes.includes(idx));

        // 按評分排序剩餘的餐廳
        remainingIndexes.sort((a, b) =>
            restaurants[b].rating - restaurants[a].rating
        );

        // 添加額外的索引以達到 3 個
        while (parsed.topIndexes.length < 3 && remainingIndexes.length > 0) {
            const newIndex = remainingIndexes.shift();
            parsed.topIndexes.push(newIndex);

            // 為新添加的索引生成推薦理由
            parsed.recommendations.push({
                index: newIndex,
                reason: `評分為 ${newIndex !== undefined ?
                    restaurants[newIndex]?.rating ??
                    "N/A" : "N/A"}，為系統根據評分自動推薦。${newIndex !==
                        undefined ? restaurants[newIndex]?.summary ??
                    "" : ""}`,
                matchScore: 0.7,  // 預設匹配分數
                matchDetail: {
                    price: 0.8,
                    distance: 0.7,
                    rating: newIndex !== undefined &&
                        restaurants[newIndex]?.rating ?
                        restaurants[newIndex].rating / 5 : 0,
                    preference: 0.6,
                    requirement: 0.5
                }
            });
        }
    }

    // 如果返回超過三個索引，只保留前三個
    if (parsed.topIndexes.length > 3) {
        console.log("警告: 模型返回了", parsed.topIndexes.length, "個索引，將只保留前 3 個");
        const keptIndexes = parsed.topIndexes.slice(0, 3);
        // 僅保留對應前三個索引的推薦理由
        if (parsed.recommendations && parsed.recommendations.length > 0) {
            parsed.recommendations = parsed.recommendations
                .filter((rec: { index: any; }) => keptIndexes.includes(rec.index))
                .slice(0, 3);
        }
        parsed.topIndexes = keptIndexes;
    }

    // 確保每個推薦的索引都有對應的理由及評分詳情
    const existingRecommendations = new Set(parsed.recommendations.map((r: { index: any; }) => r.index));

    for (const idx of parsed.topIndexes) {
        if (!existingRecommendations.has(idx)) {
            // 為缺少理由的餐廳生成推薦理由
            const restaurant = restaurants[idx as number];
            let reason = `評分為 ${restaurant?.rating ?? "N/A"}`;

            if (restaurant.reviews && restaurant.reviews.length > 0) {
                const highestReview = restaurant.reviews.sort((a: { rating: number; }, b: { rating: number; }) => b.rating - a.rating)[0];
                reason += `，顧客評價: "${highestReview.text}"`;
            }

            reason += `。${restaurant?.summary ?? "N/A"}`;

            parsed.recommendations.push({
                index: idx,
                reason: reason,
                matchScore: 0.7,  // 預設匹配分數
                matchDetail: {
                    price: 0.8,
                    distance: 0.7,
                    rating: restaurant.rating / 5,
                    preference: 0.6,
                    requirement: 0.5
                }
            });
        }
    }

    // 確保每個推薦都有 matchScore 和 matchDetail
    parsed.recommendations = parsed.recommendations.map(
        (rec: {
            matchScore: number;
            matchDetail: {
                price: number;
                distance: number;
                rating: number;
                preference: number;
                requirement: number;
            };
            index: string | number;
            reason: string;
        }) => {
            if (!rec.matchScore) {
                rec.matchScore = 0.7;  // 預設匹配分數
            }

            if (!rec.matchDetail) {
                const restaurant = restaurants[rec.index as number];
                rec.matchDetail = {
                    price: 0.8,
                    distance: 0.7,
                    rating: restaurant.rating / 5,
                    preference: 0.6,
                    requirement: 0.5
                };
            }
            // 增加 reason 檢查
            if (!rec.reason) {
                const restaurant = restaurants[rec.index as number];
                rec.reason = `評分為 ${restaurant.rating || "N/A"}。${restaurant.summary || ""}`;
            }

            return rec;
        });

    // 確保推薦理由的順序與 topIndexes 一致
    parsed.recommendations = parsed.recommendations
        .filter((rec: { index: any; }) => parsed.topIndexes.includes(rec.index))
        .sort((a: { index: any; }, b: { index: any; }) => {
            return parsed.topIndexes.indexOf(a.index) - parsed.topIndexes.indexOf(b.index);
        });

    return {
        topIndexes: parsed.topIndexes,
        recommendations: parsed.recommendations
    };
}

// 後備策略 - 當找不到足夠符合條件的餐廳時使用
async function fallbackStrategy(input: { restaurants: any; query: any; userSetting: any; }) {
    console.log("使用後備策略...");

    // 後備策略：根據使用者偏好排序並考慮所有餐廳
    const { restaurants, query, userSetting } = input;

    // 簡單的評分函數
    function scoreRestaurant(restaurant: { rating: number; distance: number; priceInformation: string; reviews: any[]; types: string; name: string; summary: string; }, query: { maxDistance: number; minPrice: number; maxPrice: number; requirement: string; }, preferences: any[]) {
        // 基本分數
        let score = restaurant.rating / 5;  // 基於評分的基礎分數

        // 距離加權 (越近越好，但不超出範圍)
        const distanceFactor = restaurant.distance <= query.maxDistance ?
            (1 - restaurant.distance / query.maxDistance) : 0;

        // 解析價格資訊
        const priceLevel = (restaurant.priceInformation.match(/\$+/) || ["$$"])[0].length;
        const averagePrice = priceLevel * 100;  // 簡單估算平均價格
        const priceFactor = averagePrice >= query.minPrice && averagePrice <= query.maxPrice ? 1 : 0.5;

        // 考慮使用者偏好
        let preferenceBonus = 0;
        preferences.forEach((preference: string, index: number) => {
            const weight = 1 - (index * 0.2);  // 第一偏好權重1，第二偏好權重0.8，依此類推

            if (preference.toLowerCase().includes("price") && priceFactor > 0.7) {
                preferenceBonus += weight * 0.3;
            }
            if (preference.toLowerCase().includes("distance") && distanceFactor > 0.7) {
                preferenceBonus += weight * 0.3;
            }
            if (preference.toLowerCase().includes("rating") && restaurant.rating >= 4) {
                preferenceBonus += weight * 0.3;
            }
            if (preference.toLowerCase().includes("review") &&
                restaurant.reviews && restaurant.reviews.some((r: { rating: number; }) => r.rating >= 4)) {
                preferenceBonus += weight * 0.3;
            }
        });

        // 考慮特定需求
        let requirementBonus = 0;
        if (query.requirement) {
            const req = query.requirement.toLowerCase();
            const types = restaurant.types.toLowerCase();
            const name = restaurant.name.toLowerCase();
            const summary = restaurant.summary.toLowerCase();

            if (types.includes(req) || name.includes(req) || summary.includes(req)) {
                requirementBonus = 0.3;
            }
        }

        // 整合所有因素
        const finalScore = (
            score * 0.3 +
            distanceFactor * 0.2 +
            priceFactor * 0.2 +
            preferenceBonus +
            requirementBonus
        );

        return {
            score: finalScore,
            matchDetail: {
                price: priceFactor,
                distance: distanceFactor,
                rating: restaurant.rating / 5,
                preference: preferenceBonus / 0.3,  // 標準化為0-1
                requirement: requirementBonus / 0.3  // 標準化為0-1
            }
        };
    }

    // 計算每家餐廳的分數
    const scoredRestaurants = restaurants.map((restaurant: any, index: any) => {
        const { score, matchDetail } = scoreRestaurant(restaurant, query, userSetting.sortedPreference);
        return { index, restaurant, score, matchDetail };
    });

    // 按分數排序
    scoredRestaurants.sort((a: { score: number; }, b: { score: number; }) => b.score - a.score);

    // 取前三名
    const topThree = scoredRestaurants.slice(0, 3);

    // 構建返回結果
    const topIndexes = topThree.map((item: { index: any; }) => item.index);
    const recommendations = topThree.map((item: { restaurant: { rating: any; distance: number; priceInformation: any; types: string; name: string; summary: any; reviews: any[]; }; index: any; score: any; matchDetail: any; }) => {
        // 生成推薦理由
        let reason = `評分為 ${item.restaurant.rating}`;

        if (item.restaurant.distance <= query.maxDistance) {
            reason += `，距離 ${item.restaurant.distance} 公尺`;
        } else {
            reason += `，雖然距離 ${item.restaurant.distance} 公尺超出了您的理想範圍`;
        }

        // 加入價格資訊
        reason += `，價格級別 ${item.restaurant.priceInformation}`;

        // 考慮使用者要求
        if (query.requirement) {
            const types = item.restaurant.types.toLowerCase();
            const name = item.restaurant.name.toLowerCase();
            if (types.includes(query.requirement.toLowerCase()) ||
                name.includes(query.requirement.toLowerCase())) {
                reason += `，符合您想要的 "${query.requirement}"`;
            }
        }

        // 添加餐廳摘要
        if (item.restaurant.summary) {
            reason += `。${item.restaurant.summary}`;
        }

        // 添加評論引用（如果有）
        if (item.restaurant.reviews && item.restaurant.reviews.length > 0) {
            const bestReview = item.restaurant.reviews.sort((a: { rating: number; }, b: { rating: number; }) => b.rating - a.rating)[0];
            reason += ` 顧客評價: "${bestReview.text}"`;
        }

        return {
            index: item.index,
            reason: reason,
            matchScore: item.score,
            matchDetail: item.matchDetail
        };
    });

    console.log("後備策略產生的索引:", topIndexes);

    return {
        topIndexes: topIndexes,
        recommendations: recommendations
    };
}