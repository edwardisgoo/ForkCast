// google_vision_service.ts (修改後的檔案)

import { z } from 'zod';
// 導入新的圖片獲取服務
import { GooglePlacesPhotosService } from './GooglePlacesPhotosService'; // 確保路徑正確

// 定義單一圖片的輸出 Schema (保持不變)
export const SinglePhotoOCROutputSchema = z.object({
  success: z.boolean().describe('是否成功辨識'),
  extractedText: z.string().describe('從圖片中辨識到的文字'),
  confidence: z.number().optional().describe('辨識信心度'),
  imageUrl: z.string().describe('實際圖片 URL'),
  photoReference: z.string().describe('對應的 photo reference'),
  error: z.string().optional().describe('錯誤訊息')
});

export type SinglePhotoOCROutput = z.infer<typeof SinglePhotoOCROutputSchema>;

/**
 * Google Vision API OCR 服務類別
 * 專注於對圖片進行 OCR 辨識
 */
export class GoogleVisionService {
  private apiKey: string;
  private placesPhotosService: GooglePlacesPhotosService; // 新增對 GooglePlacesPhotosService 的依賴

  /**
   * @param apiKey 您的 Google Cloud API Key
   */
  constructor(apiKey: string) {
    if (!apiKey) {
      throw new Error('API Key is required for GoogleVisionService.');
    }
    this.apiKey = apiKey;
    this.placesPhotosService = new GooglePlacesPhotosService(apiKey); // 初始化圖片服務
  }

  // 移除 getPhotoFromReference 方法，現在由 GooglePlacesPhotosService 提供

  /**
   * 使用 Google Cloud Vision API 對給定圖片 URL 進行文字辨識 (OCR)。
   * @param imageUrl 要進行 OCR 的圖片 URL
   * @returns 包含辨識到的文字和信心度的物件
   * @throws Error 如果 OCR 處理失敗
   */
  async performOCR(imageUrl: string): Promise<{ text: string; confidence?: number }> {
    const visionApiUrl = `https://vision.googleapis.com/v1/images:annotate?key=${this.apiKey}`;
    
    const requestBody = {
      requests: [
        {
          image: {
            source: {
              imageUri: imageUrl
            }
          },
          features: [
            {
              type: 'TEXT_DETECTION',
              maxResults: 1 
            }
          ],
          imageContext: {
            languageHints: ['zh-TW', 'zh-CN', 'en'] 
          }
        }
      ]
    };

    try {
      const response = await fetch(visionApiUrl, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(requestBody)
      });

      if (!response.ok) {
        const errorData = await response.json();
        throw new Error(`Vision API Error: ${errorData.error?.message || response.statusText}`);
      }

      const data = await response.json();
      const annotations = data.responses[0]?.textAnnotations;
      
      if (!annotations || annotations.length === 0) {
        return { text: '', confidence: 0 }; 
      }

      const fullText = annotations[0].description || '';
      const confidence = annotations[0].score || 1.0; 

      return {
        text: fullText.trim(),
        confidence: confidence
      };

    } catch (error: any) {
      throw new Error(`OCR 處理失敗: ${error.message}`);
    }
  }

  /**
   * 處理單一圖片的 OCR 流程：從 photo reference 獲取圖片，然後進行 OCR。
   * @param photoReference Google Maps API 回傳的 photo reference string
   * @param maxWidth 圖片最大寬度
   * @param maxHeight 圖片最大高度
   * @returns 單一圖片的 OCR 結果物件
   */
  async processSinglePhoto(
    photoReference: string,
    maxWidth: number,
    maxHeight: number
  ): Promise<SinglePhotoOCROutput> {
    try {
      // 1. 從 photo reference 獲取圖片 URL (現在使用 GooglePlacesPhotosService)
      const imageUrl = await this.placesPhotosService.getPhotoFromReference(
        photoReference,
        maxWidth,
        maxHeight
      );

      // 2. 對圖片進行 OCR 文字辨識
      const ocrResult = await this.performOCR(imageUrl);

      return {
        success: true,
        extractedText: ocrResult.text,
        confidence: ocrResult.confidence,
        imageUrl: imageUrl,
        photoReference: photoReference
      };

    } catch (error: any) {
      console.error(`Photo OCR Error for ${photoReference}:`, error);
      
      return {
        success: false,
        extractedText: '',
        imageUrl: '', 
        photoReference: photoReference,
        error: error.message
      };
    }
  }
}