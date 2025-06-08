import { z } from "genkit";
import { ai } from "../config";
import { gemini20Flash } from "@genkit-ai/vertexai";
import { RestaurantInputSchema } from './RestaurantInputSchema';

// 定義 RestaurantInput schema


// 定義使用者查詢參數
const QuerySchema = z.object({
    minPrice: z.number(),
    maxPrice: z.number(),
    minDistance: z.number(),
    maxDistance: z.number(),
    requirement: z.string(),
    note: z.string(),
});

// 定義使用者設定
const UserSettingSchema = z.object({
    sortedPreference: z.array(z.string()),
});

// 定義推薦理由的輸出結構
const RecommendationSchema = z.object({
    index: z.number(),
    reason: z.string(),
    matchScore: z.number(),
    matchDetail: z.object({
        price: z.number(),
        distance: z.number(),
        rating: z.number(),
        preference: z.number(),
        requirement: z.number(),
    }),
});

export const DetailSchema = z.object({
    shortIntroduction: z.string(),
    fullIntroduction: z.string(),
    menu: z.string(),
    reviews: z.string(),
    preferenceAnalysis: z.record(z.string()),
});

// 輔助函式：將排序偏好陣列轉換為字串
const convertPreferenceArrayToString = (preferences: string[]): string => {
    return preferences.join(', ');
};

// 改進的 prompt 模板 - 動態生成偏好分析區塊
const detailGenerator = ai.definePrompt({
    model: gemini20Flash,
    name: 'detailGenerator',
    messages: `
你是一個專業的餐廳介紹員，負責生成詳細、客觀的餐廳介紹。

**重要格式要求：**
- 每個區塊必須以 "===SECTION_NAME===" 開始，以 "===END_SECTION_NAME===" 結束
- 區塊之間不能有重疊內容
- 每個區塊內容必須完整且獨立

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

使用者偏好（按重要性排序）：{{preferenceString}}

推薦理由：{{recommendationReason}}
匹配分數：{{recommendationMatchScore}}

請嚴格按照以下格式輸出：

===SHORT_INTRO===
[簡短二十字內概述該餐廳的特色和為何推薦給使用者]
===END_SHORT_INTRO===

===FULL_INTRO===
[詳細描述餐廳的氛圍、特色和整體體驗，約100-150字]
===END_FULL_INTRO===

===MENU===
推薦菜品：
• [菜品名稱1]：[描述和價格]
• [菜品名稱2]：[描述和價格]
• [菜品名稱3]：[描述和價格]

備註：[關於菜單的額外說明]
===END_MENU===

===REVIEWS===
優點：
• [優點1]
• [優點2]
• [優點3]

缺點：
• [缺點1]
• [缺點2]
===END_REVIEWS===

{{preferenceAnalysisPrompt}}

請使用中文回覆，並嚴格遵守上述格式。
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
            preferenceAnalysisPrompt: z.string(), // 動態生成的偏好分析提示
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

// 改進的解析函數 - 使用新的格式標記
function extractSectionByMarkers(sectionKey: string, content: string): string {
    console.log(`嘗試提取區塊: ${sectionKey}`);
    
    // 清理內容
    const cleanedContent = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    
    // 構建開始和結束標記
    const startMarker = `===${sectionKey}===`;
    const endMarker = `===END_${sectionKey}===`;
    
    console.log(`查找標記: ${startMarker} 到 ${endMarker}`);
    
    const startIndex = cleanedContent.indexOf(startMarker);
    const endIndex = cleanedContent.indexOf(endMarker);
    
    if (startIndex === -1) {
        console.log(`未找到開始標記: ${startMarker}`);
        return `未能提取${sectionKey}部分`;
    }
    
    if (endIndex === -1) {
        console.log(`未找到結束標記: ${endMarker}`);
        // 如果沒有找到結束標記，嘗試找到下一個區塊的開始
        const nextSectionRegex = /===\w+===/g;
        const matches = [...cleanedContent.matchAll(nextSectionRegex)];
        const currentSectionIndex = matches.findIndex(match => match.index === startIndex);
        
        if (currentSectionIndex !== -1 && currentSectionIndex < matches.length - 1) {
            const nextSectionStart = matches[currentSectionIndex + 1].index!;
            const extracted = cleanedContent.slice(startIndex + startMarker.length, nextSectionStart).trim();
            console.log(`使用下一個區塊邊界提取: ${sectionKey}`);
            return extracted || `未能提取${sectionKey}部分`;
        } else {
            // 取到文檔結尾
            const extracted = cleanedContent.slice(startIndex + startMarker.length).trim();
            console.log(`提取到文檔結尾: ${sectionKey}`);
            return extracted || `未能提取${sectionKey}部分`;
        }
    }
    
    // 正常情況：找到開始和結束標記
    const extracted = cleanedContent.slice(startIndex + startMarker.length, endIndex).trim();
    console.log(`成功提取區塊: ${sectionKey}, 長度: ${extracted.length}`);
    
    return extracted || `未能提取${sectionKey}部分`;
}

// 備用解析函數 - 如果標記格式失敗，使用改進的舊方法
function extractSectionFallback(sectionName: string, content: string): string {
    console.log(`使用備用方法提取: ${sectionName}`);
    
    const cleanedContent = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    
    // 多種模式匹配
    const patterns = [
        // 模式1: ===名稱===
        new RegExp(`===${sectionName}===\\s*([\\s\\S]*?)(?===\\w+===|$)`, 'i'),
        // 模式2: **名稱：**
        new RegExp(`\\*\\*${sectionName}[：:]\\*\\*\\s*([\\s\\S]*?)(?=\\n\\*\\*[\\u4e00-\\u9fa5][\\u4e00-\\u9fa5]*[：:]\\*\\*|$)`, 'i'),
        // 模式3: 名稱：
        new RegExp(`${sectionName}[：:]\\s*([\\s\\S]*?)(?=\\n[\\u4e00-\\u9fa5]{2,}[：:]|$)`, 'i'),
    ];
    
    for (let i = 0; i < patterns.length; i++) {
        const match = cleanedContent.match(patterns[i]);
        if (match && match[1] && match[1].trim()) {
            console.log(`備用方法模式${i + 1}成功匹配: ${sectionName}`);
            return match[1].trim();
        }
    }
    
    console.log(`備用方法也失敗: ${sectionName}`);
    return `未能提取${sectionName}部分`;
}

// 改進的內容清理函數
function cleanExtractedContent(content: string): string {
    if (!content) return "";
    
    // 移除 BOM 和特殊字符
    content = content.replace(/^\uFEFF/, '');
    
    // 移除開頭的特殊標記
    content = content.replace(/^[\*\-\+\s]*/, "");
    
    // 標準化換行符
    content = content.replace(/\r\n/g, '\n').replace(/\r/g, '\n');
    
    // 移除過多的空行
    content = content.replace(/\n{3,}/g, "\n\n");
    
    // 移除行首的過多空格（但保留縮進結構）
    content = content.replace(/^[ \t]+/gm, '');
    
    // 移除行尾空格
    content = content.replace(/[ \t]+$/gm, '');
    
    return content.trim();
}

// 輔助函數：安全地提取文本內容
function extractTextContent(content: any): string {
    if (typeof content === 'string') {
        return content;
    }
    
    if (content && typeof content === 'object') {
        // 如果是包含 text 屬性的對象
        if ('text' in content && typeof content.text === 'string') {
            return content.text;
        }
        
        // 如果是其他類型的對象，嘗試轉換為字符串
        return String(content);
    }
    
    return '';
}

// 主要的流程函數
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
            console.log("開始生成詳細資訊...");
            
            const preferences = input.userSetting.sortedPreference;
            const preferenceString = convertPreferenceArrayToString(preferences);
            
            console.log("偏好設定:", preferences);
            
            // 動態生成偏好分析的 prompt 部分
            const preferenceAnalysisPrompt = preferences.map(pref => 
                `===${pref}分析===\n[分析餐廳在${pref}方面如何符合使用者需求，提供具體例子，約50-80字]\n===END_${pref}分析===`
            ).join('\n\n');
            
            console.log("生成的偏好分析提示:", preferenceAnalysisPrompt);
            
            // 調用 AI 生成詳細介紹
            const detailResponse = await detailGenerator({
                restaurantName: input.restaurant.name,
                restaurantTypes: input.restaurant.types,
                restaurantRating: input.restaurant.rating,
                restaurantDistance: Math.round(input.restaurant.distance),
                restaurantOpening: input.restaurant.opening ? '是' : '否',
                restaurantPriceInfo: input.restaurant.priceInformation,
                restaurantPhotoInfo: input.restaurant.photoInformation,
                restaurantSummary: input.restaurant.summary,
                restaurantExtraInfo: input.restaurant.extraInformation,
                queryMinPrice: input.query.minPrice,
                queryMaxPrice: input.query.maxPrice,
                queryMinDistance: input.query.minDistance,
                queryMaxDistance: input.query.maxDistance,
                queryRequirement: input.query.requirement,
                queryNote: input.query.note,
                preferenceString: preferenceString,
                preferenceAnalysisPrompt: preferenceAnalysisPrompt, // 動態生成的偏好分析提示
                recommendationReason: input.previousRecommendation.reason,
                recommendationMatchScore: input.previousRecommendation.matchScore,
                matchDetailPrice: input.previousRecommendation.matchDetail.price,
                matchDetailDistance: input.previousRecommendation.matchDetail.distance,
                matchDetailRating: input.previousRecommendation.matchDetail.rating,
                matchDetailPreference: input.previousRecommendation.matchDetail.preference,
                matchDetailRequirement: input.previousRecommendation.matchDetail.requirement
            });

            // 提取AI回應的文本內容 - 修復的部分
            let detailContent = "";
            if (detailResponse?.message?.content) {
                if (Array.isArray(detailResponse.message.content) && detailResponse.message.content.length > 0) {
                    const contentObj = detailResponse.message.content[0];
                    detailContent = extractTextContent(contentObj); // 使用輔助函數
                } else if (typeof detailResponse.message.content === 'string') {
                    detailContent = detailResponse.message.content;
                } else {
                    // 處理其他可能的內容格式
                    detailContent = extractTextContent(detailResponse.message.content);
                }
            }

            console.log("AI 回應長度:", detailContent.length);
            console.log("AI 回應前500字符:", detailContent.substring(0, 500));

            if (!detailContent || detailContent.length < 50) {
                throw new Error("AI 回應內容不足");
            }

            // 使用新的解析方法
            const shortIntroduction = cleanExtractedContent(
                extractSectionByMarkers("SHORT_INTRO", detailContent)
            );
            
            const fullIntroduction = cleanExtractedContent(
                extractSectionByMarkers("FULL_INTRO", detailContent)
            );
            
            const menu = cleanExtractedContent(
                extractSectionByMarkers("MENU", detailContent)
            );
            
            const reviews = cleanExtractedContent(
                extractSectionByMarkers("REVIEWS", detailContent)
            );

            // 提取偏好分析
            const preferenceAnalysis: Record<string, string> = {};
            preferences.forEach(pref => {
                const analysisKey = `${pref}分析`;
                let analysisContent = cleanExtractedContent(
                    extractSectionByMarkers(analysisKey, detailContent)
                );
                
                // 如果標記方法失敗，嘗試備用方法
                if (analysisContent.includes("未能提取")) {
                    analysisContent = cleanExtractedContent(
                        extractSectionFallback(analysisKey, detailContent)
                    );
                }
                
                preferenceAnalysis[pref] = analysisContent;
            });

            const result = {
                shortIntroduction,
                fullIntroduction,
                menu,
                reviews,
                preferenceAnalysis
            };

            console.log("解析結果摘要:");
            console.log(`- 短介紹長度: ${shortIntroduction.length}`);
            console.log(`- 完整介紹長度: ${fullIntroduction.length}`);
            console.log(`- 菜單推薦長度: ${menu.length}`);
            console.log(`- 評論摘要長度: ${reviews.length}`);
            console.log(`- 偏好分析項目數: ${Object.keys(preferenceAnalysis).length}`);

            return result;

        } catch (error) {
            console.error("詳細餐廳資訊生成失敗:", error);
            
            // 返回基本的錯誤恢復內容
            const restaurant = input.restaurant;
            const preferences = input.userSetting.sortedPreference;
            
            const preferenceAnalysis: Record<string, string> = {};
            preferences.forEach((pref: string) => {
                preferenceAnalysis[pref] = `這家餐廳在${pref}方面符合您的基本需求。`;
            });

            return {
                shortIntroduction: `${restaurant.name}是一家評分${restaurant.rating}分的${restaurant.types}`,
                fullIntroduction: `${restaurant.name}位於距離您${restaurant.distance}公尺的位置，提供${restaurant.types}美食。${restaurant.summary}`,
                menu: `推薦您嘗試這家餐廳的招牌菜品。詳細菜單請現場詢問或查看外送平台。`,
                reviews: `根據顧客評價，這家餐廳整體表現良好，評分為${restaurant.rating}分。`,
                preferenceAnalysis
            };
        }
    }
);