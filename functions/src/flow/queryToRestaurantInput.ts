import { ai } from "../config";
import { z } from 'zod';
import { placesGetRestaurantRawFlow, RestaurantQuerySchema } from './actions/GooglePlacesGetRestaurantRaw';
import {RestaurantRawSchema} from './services/GooglePlacesSchemas';
import { photosOCRFlow } from './getImageText'; // 導入 OCR flow
import { RestaurantInputSchema } from './RestaurantInputSchema';
import {
  PriceLevel,
  typeMap,
} from './services/GooglePlacesTypes';

// 確保類型正確導入
type RestaurantRawType = z.infer<typeof RestaurantRawSchema>;

// QueryTime Schema (已移除 dayOfWeek 欄位)
const QueryTimeSchema = z.object({
  hour: z.number().min(0).max(23),
  minute: z.number().min(0).max(59),
});



// 主要的 Flow - 修正版本
export const restaurantQueryFlow = ai.defineFlow(
  {
    name: 'restaurantRawToRestaurantInput',
    inputSchema: z.object({
      query: RestaurantQuerySchema,
      queryTime: QueryTimeSchema, // 保持為新的 QueryTimeSchema
    }),
    outputSchema: z.array(RestaurantInputSchema),
  },
  async (params) => {
    const rawRestaurants = await placesGetRestaurantRawFlow(params.query);

    // 轉換每個 RestaurantRaw 為 RestaurantInput (並行處理)
    const restaurantInputsPromises = rawRestaurants.map(raw =>
      convertRawToInput(raw, params.queryTime, params.query.latitude, params.query.longitude)
    );

    // 使用 Promise.allSettled 來處理可能的回傳 null 的情況
    const settledResults = await Promise.allSettled(restaurantInputsPromises);

    const restaurantInputs = settledResults
      .filter(result => result.status === 'fulfilled' && result.value !== null) // 過濾掉未營業或處理失敗的餐廳
      .map(result => (result as PromiseFulfilledResult<z.infer<typeof RestaurantInputSchema>>).value);

    if (restaurantInputs.length === 0) {
      console.log("沒有找到任何當前營業或符合條件的餐廳。");
      return []; // 返回空陣列
    }

    return restaurantInputs;
  }
);

// 轉換函數 (對應 Dart 的 RestaurantInput.fromRaw) - 修正類型
async function convertRawToInput(
  raw: RestaurantRawType,
  queryTime: { hour: number; minute: number; }, // 已移除 dayOfWeek 欄位
  queryLat: number,
  queryLng: number
): Promise<z.infer<typeof RestaurantInputSchema> | null> { // 回傳類型改為可能為 null

  let isOpen = false;
  // **在函數內部獲取當前星期幾**
  const currentDayOfWeek = new Date().getDay(); // 0 = Sunday, 1 = Monday, ..., 6 = Saturday

  // 檢查是否有開放時間資訊
  // 如果沒有 openingHours 或其為空陣列，則無法判斷營業狀態，視為不營業
  if (!raw.openingHours || raw.openingHours.length === 0) {
    return null;
  }

  // 篩選出當前星期幾的營業時間區段
  const todayPeriods = raw.openingHours.filter(period => period.day === currentDayOfWeek);

  // 如果當天沒有任何營業時間區段，則不營業
  if (todayPeriods.length === 0) {
    return null;
  }

  // 判斷是否在當前時間營業
  for (const period of todayPeriods) {
    const openMinutes = period.start.hour * 60 + period.start.minute;
    const closeMinutes = period.end.hour * 60 + period.end.minute;
    const queryMinutes = queryTime.hour * 60 + queryTime.minute;

    // 處理跨午夜的情況
    if (closeMinutes < openMinutes) {
      if (queryMinutes >= openMinutes || queryMinutes <= closeMinutes) {
        isOpen = true;
        break; // 找到一個營業時段即可跳出
      }
    } else {
      // 正常當天營業的情況
      if (queryMinutes >= openMinutes && queryMinutes <= closeMinutes) {
        isOpen = true;
        break; // 找到一個營業時段即可跳出
      }
    }
  }

  // 如果不在營業中，直接返回 null，不進行後續處理
  if (!isOpen) {
    return null;
  }

  // 以下是原有邏輯，只有在確定營業時才會執行

  // 計算距離 (Haversine Formula)
  const distance = calculateDistanceMeters(
    raw.latitude,
    raw.longitude,
    queryLat,
    queryLng
  );

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

  // 處理價位資訊
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
    id:raw.id,
    distance: distance,
    opening: isOpen,
    rating: raw.rating || 0,
    reviews: processedReviews,
    photoInformation: photoInfo,
    name: raw.name,
    summary: '',
    types: typeStrings,
    priceInformation: priceInfo,
    extraInformation: extraInfo,
    openingHours:raw.openingHours,
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
    const ocrResult = await photosOCRFlow({
      photoReferences: photos,
      maxWidth: 1600,
      maxHeight: 1600
    });

    if (ocrResult.menuImageCount > 0 && ocrResult.information.length > 0) {
      return `共 ${photos.length} 張照片，成功辨識 ${ocrResult.menuImageCount} 張菜單圖片。菜單內容：${ocrResult.information.substring(0, 500)}${ocrResult.information.length > 500 ? '...' : ''}`;
    }

    if (ocrResult.successCount > 0) {
      return `共 ${photos.length} 張照片，成功處理 ${ocrResult.successCount} 張，但未辨識到明確的菜單內容`;
    }

    return `共 ${photos.length} 張照片，處理失敗`;

  } catch (error) {
    console.error('OCR 處理錯誤:', error);
    return `共 ${photos.length} 張照片，OCR 處理時發生錯誤`;
  }
}