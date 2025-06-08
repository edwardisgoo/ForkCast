import { 
  BusinessStatus, 
  PriceLevel, 
  OpeningHoursPeriod,
  Review,
  TimePeriod,
  typeMap
//   PlaceBase,
//   PlaceDetails
} from './GooglePlacesTypes';

export function parseBusinessStatus(status?: string): BusinessStatus {
  if (!status) return BusinessStatus.CLOSED_PERMANENTLY;
  
  switch (status.toUpperCase()) {
    case 'OPERATIONAL': return BusinessStatus.OPERATIONAL;
    case 'CLOSED_TEMPORARILY': return BusinessStatus.CLOSED_TEMPORARILY;
    case 'CLOSED_PERMANENTLY': return BusinessStatus.CLOSED_PERMANENTLY;
    default: return BusinessStatus.CLOSED_PERMANENTLY;
  }
}

export function parsePriceLevel(level?: number): PriceLevel {
  if (level === undefined || level < 0 || level > 4) {
    return PriceLevel.MODERATE;
  }
  return level;
}
export function parseOpeningHours(
  periods: OpeningHoursPeriod[] | undefined // 接受 OpeningHoursPeriod 類型
): TimePeriod[] | undefined { // 返回 TimePeriod 類型
  if (!periods || periods.length === 0) {
    return undefined;
  }

  const parsedPeriods: TimePeriod[] = [];

  for (const period of periods) {
    // 確保 open 屬性存在，並且 day 和 time 存在
    if (!period.open || period.open.day === undefined || !period.open.time) {
      console.warn("Warning: Malformed 'open' period in Google Places opening hours. Skipping:", period);
      continue;
    }

    // 獲取 day (通常在 open.day 中)
    const day = period.open.day;

    // 解析開始時間
    const startHour = parseInt(period.open.time.substring(0, 2), 10);
    const startMinute = parseInt(period.open.time.substring(2, 4), 10);

    // 檢查結束時間是否存在，如果不存在，則視為當天結束（例如：午夜 23:59 或開到午夜）
    // Google API 規定如果只有 open 而沒有 close，表示營業到午夜。
    // 但為確保安全，我們嘗試從 close 中獲取，如果沒有，可以假設為當天營業結束。
    // 在這裡，我們假設如果沒有 close，就是開到當天午夜 23:59 比較安全。
    // 更準確的做法是查詢 Google Places API 文件對於單個 'open' 節點的行為。
    // 目前範例中的數據都有 'start' 和 'end'，所以我們基於此。
    
    // 如果沒有 close 屬性，或者 close.time 不存在，需要定義一個合理的預設值
    // 這裡我假設如果沒有 close，就設定為當天結束 (23:59)
    const endHour = period.close && period.close.time ? parseInt(period.close.time.substring(0, 2), 10) : 23;
    const endMinute = period.close && period.close.time ? parseInt(period.close.time.substring(2, 4), 10) : 59;

    // 驗證解析出的時間是否為有效數字
    if (isNaN(startHour) || isNaN(startMinute) || isNaN(endHour) || isNaN(endMinute)) {
      console.warn("Warning: Invalid time format in Google Places opening hours. Skipping period:", period);
      continue;
    }

    // 將轉換後的 TimePeriod 推入陣列
    parsedPeriods.push({
      day: day,
      start: { hour: startHour, minute: startMinute },
      end: { hour: endHour, minute: endMinute }
    });
  }

  // 如果解析後沒有任何有效的時段，返回 undefined
  return parsedPeriods.length > 0 ? parsedPeriods : undefined;
}


export function parseReviews(reviews?: Review[]): Review[] {
  if (!reviews || !Array.isArray(reviews)) return [];
  
  return reviews.map(review => ({
    author_name: review.author_name || '',
    author_url: review.author_url || '',
    language: review.language || '',
    profile_photo_url: review.profile_photo_url || '',
    rating: review.rating || 0,
    relative_time_description: review.relative_time_description || '',
    text: review.text || '',
    time: review.time || 0,
    translated: review.translated || false
  }));
}

export function parseTypes(types?: string[]): Set<number> {
  if (!types || !Array.isArray(types)) return new Set();
  
  // This assumes you have a typeMap defined elsewhere that maps
  // Google Place types to your internal numeric identifiers
  const typeIndexes = new Set<number>();
  
  types.forEach(type => {
    const index = Object.keys(typeMap).indexOf(type);
    if (index !== -1) {
      typeIndexes.add(index);
    }
  });
  
  return typeIndexes;
}