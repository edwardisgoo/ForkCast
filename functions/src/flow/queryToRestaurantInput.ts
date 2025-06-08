import { ai } from "../config";
import { z } from 'zod';
import { placesGetRestaurantRawFlow, RestaurantRawSchema, RestaurantQuerySchema } from './actions/GooglePlacesGetRestaurantRaw';
import { photosOCRFlow } from './getImageText'; // 導入 OCR flow
import {
  PriceLevel,
  typeMap,
} from './services/GooglePlacesTypes';

// 確保類型正確導入
type RestaurantRawType = z.infer<typeof RestaurantRawSchema>;

// QueryTime Schema
const QueryTimeSchema = z.object({
  hour: z.number().min(0).max(23),
  minute: z.number().min(0).max(59)
});

// RestaurantInput Schema (對應 Dart 的 RestaurantInput)
export const RestaurantInputSchema = z.object({
  distance: z.number(),
  opening: z.boolean(),
  rating: z.number(),
  reviews: z.array(z.object({
    rating: z.number(),
    time: z.string(),
    text: z.string()
  })),
  photoInformation: z.string(), // 修正拼寫錯誤
  name: z.string(),
  summary: z.string(),
  types: z.string(),
  priceInformation: z.string(),
  extraInformation: z.string()
});

// 主要的 Flow - 修正版本 (改為 async)
export const restaurantQueryFlow = ai.defineFlow(
  {
    name: 'restaurantRawToRestaurantInput',
    inputSchema: z.object({
      query: RestaurantQuerySchema,
      queryTime: QueryTimeSchema,
    }),
    outputSchema: z.array(RestaurantInputSchema),
  },
  async (params) => {
    const rawRestaurants = await placesGetRestaurantRawFlow(params.query);
    
    // 轉換每個 RestaurantRaw 為 RestaurantInput (並行處理)
    const restaurantInputs = await Promise.all(
      rawRestaurants.map(raw => 
        convertRawToInput(raw, params.queryTime, params.query.latitude, params.query.longitude)
      )
    );
    if (restaurantInputs.length === 0) {
      throw new Error("placesGetRestaurantRawFlow回傳0個餐廳");
    }
    
    return restaurantInputs;
  }
);

// 轉換函數 (對應 Dart 的 RestaurantInput.fromRaw) - 修正類型
async function convertRawToInput(
  raw: RestaurantRawType,
  queryTime: { hour: number; minute: number },
  queryLat: number,
  queryLng: number
): Promise<z.infer<typeof RestaurantInputSchema>> {
  
  // 計算距離 (Haversine Formula)
  const distance = calculateDistanceMeters(
    raw.latitude,
    raw.longitude,
    queryLat,
    queryLng
  );
  
  // 判斷是否營業中
  const isOpen = raw.openingHours ? raw.openingHours.some((period) => {
    const openMinutes = period.start.hour * 60 + period.start.minute;
    const closeMinutes = period.end.hour * 60 + period.end.minute;
    const queryMinutes = queryTime.hour * 60 + queryTime.minute;
    
    // 處理跨午夜的情況
    if (closeMinutes < openMinutes) {
      return queryMinutes >= openMinutes || queryMinutes <= closeMinutes;
    } else {
      return queryMinutes >= openMinutes && queryMinutes <= closeMinutes;
    }
  }) : false;
  
  // Types 轉文字 - 處理 Set<number> 類型
  let typeStrings = '未知';
  if (raw.types && raw.types.size > 0) {
    const keys = Object.keys(typeMap);
    const typeArray = Array.from(raw.types);
    typeStrings = typeArray
      .map((index) => {
        const key = keys[index as number];
        return typeMap[key] || '未知';
      })
      .join(' / ') || '未知';
  }
  
  // 處理價位資訊 - 修正版本
  const priceInfo = raw.priceLevel !== undefined ? {
    [PriceLevel.FREE]: '免費',
    [PriceLevel.INEXPENSIVE]: '便宜', 
    [PriceLevel.MODERATE]: '中等',
    [PriceLevel.EXPENSIVE]: '貴',
    [PriceLevel.VERY_EXPENSIVE]: '非常貴'
  }[raw.priceLevel] || '未知' : '未知';
  
  // 處理照片資訊 - 使用 OCR flow
  const photoInfo = await ocrImageProcess(raw.photos);
  
  // 合成額外資訊
  const extras: string[] = [];
  if (raw.delivery) extras.push('外送');
  if (raw.dineIn) extras.push('內用');
  if (raw.reservable) extras.push('可預約');
  if (raw.servesBeer) extras.push('提供啤酒');
  if (raw.servesWine) extras.push('葡萄酒');
  if (raw.takeout) extras.push('外帶');
  if (raw.wheelchairAccessibleEntrance) extras.push('無障礙入口');
  const extraInfo = extras.join(' / ');
  
  // 處理評論資料
  const processedReviews = (raw.reviews || []).map((review) => ({
    rating: review.rating,
    time: typeof review.time === 'number' ? 
      new Date(review.time * 1000).toISOString() : 
      String(review.time),
    text: review.text
  }));
  
  return {
    distance: distance,
    opening: isOpen,
    rating: raw.rating || 0,
    reviews: processedReviews,
    photoInformation: photoInfo, // 修正拼寫
    name: raw.name,
    summary: '', // 由於 RestaurantRawSchema 中沒有 summary，使用空字串
    types: typeStrings,
    priceInformation: priceInfo,
    extraInformation: extraInfo
  };
}

// 計算兩點間距離的函數 (Haversine Formula)
function calculateDistanceMeters(
  lat1: number, 
  lng1: number, 
  lat2: number, 
  lng2: number
): number {
  const R = 6371000; // 地球半徑 (公尺)
  const dLat = (lat2 - lat1) * Math.PI / 180;
  const dLng = (lng2 - lng1) * Math.PI / 180;
  
  const a = 
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
    Math.sin(dLng / 2) * Math.sin(dLng / 2);
  
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

// OCR 圖片處理函數 - 使用真實的 OCR flow
async function ocrImageProcess(photos: string[]): Promise<string> {
  if (!photos || photos.length === 0) {
    return '無照片資訊';
  }
  
  try {
    // 調用 OCR flow 來處理圖片
    const ocrResult = await photosOCRFlow({
      photoReferences: photos,
      maxWidth: 1600,
      maxHeight: 1600
    });
    
    // 如果有成功辨識到菜單內容，返回辨識結果
    if (ocrResult.menuImageCount > 0 && ocrResult.information.length > 0) {
      return `共 ${photos.length} 張照片，成功辨識 ${ocrResult.menuImageCount} 張菜單圖片。菜單內容：${ocrResult.information.substring(0, 500)}${ocrResult.information.length > 500 ? '...' : ''}`;
    }
    
    // 如果沒有辨識到菜單內容，但有成功處理的圖片
    if (ocrResult.successCount > 0) {
      return `共 ${photos.length} 張照片，成功處理 ${ocrResult.successCount} 張，但未辨識到明確的菜單內容`;
    }
    
    // 如果都失敗了
    return `共 ${photos.length} 張照片，處理失敗`;
    
  } catch (error) {
    console.error('OCR 處理錯誤:', error);
    return `共 ${photos.length} 張照片，OCR 處理時發生錯誤`;
  }
}