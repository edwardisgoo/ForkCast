// 基本型別
export interface Location {
  lat: number;
  lng: number;
}

export interface Viewport {
  northeast: Location;
  southwest: Location;
}

export interface Geometry {
  location: Location;
  viewport: Viewport;
}

export interface Photo {
  height: number;
  width: number;
  html_attributions: string[];
  photo_reference: string;
}

export interface PlusCode {
  compound_code: string;
  global_code: string;
}

export interface Review {
  author_name: string;
  author_url: string;
  language: string;
  profile_photo_url: string;
  rating: number;
  relative_time_description: string;
  text: string;
  time: number;
  translated?: boolean;
}


export interface TimePeriod {
  start: { hour: number; minute: number };
  end: { hour: number; minute: number };
}

export interface OpeningHoursPeriod {
  open: {
    day: number;
    time: string;
    date?: string;
  };
  close?: {
    day: number;
    time: string;
    date?: string;
  };
}

export interface CurrentOpeningHours {
  open_now: boolean;
  periods?: OpeningHoursPeriod[];
  weekday_text?: string[];
}

export interface EditorialSummary {
  overview: string;
}

// 狀態和價格等級列舉
export enum BusinessStatus {
  OPERATIONAL = "OPERATIONAL",
  CLOSED_TEMPORARILY = "CLOSED_TEMPORARILY",
  CLOSED_PERMANENTLY = "CLOSED_PERMANENTLY"
}

export enum PriceLevel {
  FREE = 0,
  INEXPENSIVE = 1,
  MODERATE = 2,
  EXPENSIVE = 3,
  VERY_EXPENSIVE = 4
}

// API 回應型別
export interface PlacesApiResponse<T> {
  html_attributions: string[];
  status: string;
  error_message?: string;
  next_page_token?: string;
  results?: T[];
  result?: T;
}

// 搜尋參數型別
export interface NearbySearchParams {
  latitude: number;
  longitude: number;
  radius?: number;
  type?: string;
  keyword?: string;
  minprice?: PriceLevel;
  maxprice?: PriceLevel;
  opennow?: boolean;
  rankby?: 'prominence' | 'distance'; // New param
  maxResults?: number; // New param to limit results
}

export interface DetailsSearchParams {
  placeId: string;
  fields?: string;
}

// Common basic type for all place responses
export interface PlaceBasic {
  id: string;
  name: string;
  address: string;
  latitude: number;
  longitude: number;
  types: Set<number>;
  photos: string[];
  rating?: number;
  priceLevel?: PriceLevel;
  businessStatus: BusinessStatus;
  openingHours?: TimePeriod[];
}

// Nearby search specific type
export interface NearbyPlace extends PlaceBasic {
  vicinity: string;
  userRatingsTotal?: number;
}

// Details search specific type
export interface PlaceDetails extends PlaceBasic {
  formattedAddress: string;
  internationalPhoneNumber?: string;
  website?: string;
  reviews: Review[];
  // Amenities
  dineIn: boolean;
  takeout: boolean;
  delivery: boolean;
  reservable: boolean;
  servesBeer: boolean;
  servesWine: boolean;
  // Additional fields
  editorialSummary?: string;
  url: string;
  wheelchairAccessibleEntrance: boolean;
    currentOpeningHours?: {
    openNow: boolean;
    periods: TimePeriod[]; // Using TimePeriod here
    weekdayText: string[];
  };
}


export const typeMap: { [key: string]: string } = {
  'accounting': '會計',
  'airport': '機場',
  'amusement_park': '遊樂園',
  'aquarium': '水族館',
  'art_gallery': '藝術畫廊',
  'atm': '提款機',
  'bakery': '麵包店',
  'bank': '銀行',
  'bar': '酒吧',
  'beauty_salon': '美容院',
  'bicycle_store': '腳踏車店',
  'book_store': '書店',
  'bowling_alley': '保齡球館',
  'bus_station': '公車站',
  'cafe': '咖啡館',
  'campground': '露營地',
  'car_dealer': '汽車經銷商',
  'car_rental': '汽車租賃',
  'car_repair': '汽車維修',
  'car_wash': '洗車場',
  'casino': '賭場',
  'cemetery': '墓園',
  'church': '教堂',
  'city_hall': '市政廳',
  'clothing_store': '服飾店',
  'convenience_store': '便利商店',
  'courthouse': '法院',
  'dentist': '牙醫',
  'department_store': '百貨公司',
  'doctor': '醫生',
  'drugstore': '藥局',
  'electrician': '電工',
  'electronics_store': '電子產品商店',
  'embassy': '大使館',
  'fire_station': '消防局',
  'florist': '花店',
  'funeral_home': '殯儀館',
  'furniture_store': '傢俱店',
  'gas_station': '加油站',
  'gym': '健身房',
  'hair_care': '美髮',
  'hardware_store': '五金行',
  'hindu_temple': '印度廟',
  'home_goods_store': '家居用品店',
  'hospital': '醫院',
  'insurance_agency': '保險公司',
  'jewelry_store': '珠寶店',
  'laundry': '洗衣店',
  'lawyer': '律師事務所',
  'library': '圖書館',
  'light_rail_station': '輕軌站',
  'liquor_store': '酒類專賣店',
  'local_government_office': '地方政府機構',
  'locksmith': '鎖匠',
  'lodging': '住宿',
  'meal_delivery': '餐點外送',
  'meal_takeaway': '外帶餐點',
  'mosque': '清真寺',
  'movie_rental': '錄影帶出租店',
  'movie_theater': '電影院',
  'moving_company': '搬家公司',
  'museum': '博物館',
  'night_club': '夜店',
  'painter': '油漆工',
  'park': '公園',
  'parking': '停車場',
  'pet_store': '寵物店',
  'pharmacy': '藥房',
  'physiotherapist': '物理治療師',
  'plumber': '水電工',
  'police': '警察局',
  'post_office': '郵局',
  'primary_school': '小學',
  'real_estate_agency': '房地產仲介',
  'restaurant': '餐廳',
  'roofing_contractor': '屋頂承包商',
  'rv_park': '露營車公園',
  'school': '學校',
  'secondary_school': '中學',
  'shoe_store': '鞋店',
  'shopping_mall': '購物中心',
  'spa': '水療中心',
  'stadium': '體育館',
  'storage': '倉儲',
  'store': '商店',
  'subway_station': '地鐵站',
  'supermarket': '超市',
  'synagogue': '猶太會堂',
  'taxi_stand': '計程車招呼站',
  'tourist_attraction': '觀光景點',
  'train_station': '火車站',
  'transit_station': '交通站',
  'travel_agency': '旅行社',
  'university': '大學',
  'veterinary_care': '獸醫診所',
  'zoo': '動物園',
};
