// google_places_photos_service.ts

import { z } from 'zod';

// 定義 Schema (如果需要，也可以選擇放在一個共同的 schema 檔案中)
export const PhotoReferenceInputSchema = z.object({
  photoReference: z.string().describe('Google Maps API 回傳的 photo reference string'),
  maxWidth: z.number().optional().default(2000).describe('圖片最大寬度'),
  maxHeight: z.number().optional().default(2000).describe('圖片最大高度')
});

export type PhotoReferenceInput = z.infer<typeof PhotoReferenceInputSchema>;

/**
 * Google Places Photos Service 類別
 * 專門用於從 Google Maps Places API 獲取圖片 URL
 */
export class GooglePlacesPhotosService {
  private apiKey: string;

  /**
   * @param apiKey 您的 Google Cloud API Key
   */
  constructor(apiKey: string) {
    if (!apiKey) {
      throw new Error('API Key is required for GooglePlacesPhotosService.');
    }
    this.apiKey = apiKey;
  }

  /**
   * 從 Google Maps photo reference 獲取實際圖片的 URL。
   * Google Maps Photo API 會返回一個 302 重定向到實際的圖片 URL。
   * @param photoReference Google Maps API 回傳的 photo reference string
   * @param maxWidth 圖片最大寬度 (選填，預設 2000)
   * @param maxHeight 圖片最大高度 (選填，預設 2000)
   * @returns 實際圖片的 URL
   * @throws Error 如果無法獲取圖片 URL
   */
  async getPhotoFromReference(
    photoReference: string, 
    maxWidth: number = 2000, 
    maxHeight: number = 2000
  ): Promise<string> {
    const photoUrl = `https://maps.googleapis.com/maps/api/place/photo?photoreference=${photoReference}&maxwidth=${maxWidth}&maxheight=${maxHeight}&key=${this.apiKey}`;
    
    try {
      // 獲取實際圖片 URL（Google 會重定向到實際圖片）
      const response = await fetch(photoUrl, {
        method: 'GET',
        redirect: 'manual' // 不自動跟隨重定向
      });
      
      if (response.status === 302) {
        const location = response.headers.get('location');
        if (location) {
          return location;
        }
      }
      
      // 如果沒有重定向，但響應是成功的，直接返回原 URL (通常不應該發生，但作為fallback)
      if (response.ok) {
        return photoUrl;
      }
      
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    } catch (error: any) {
      throw new Error(`無法獲取圖片: ${error.message}`);
    }
  }
}