// photos_ocr_flow.ts (保持不變)

import { ai } from "../../config";
import { API } from "../../config";
import { z } from 'zod';
import * as functions from 'firebase-functions';

// 從新的檔案導入 GoogleVisionService 和相關 Schema
import {SinglePhotoOCROutputSchema, GoogleVisionService } from '../services/GoogleVisionService'; // 確保路徑正確

// 輸入 Schema：Google Maps API 回傳的 photos string array（使用固定的 API key）
const PhotosOCRInputSchema = z.object({
  photoReferences: z.array(z.string()).describe('Google Maps API 回傳的 photo reference string 陣列'),
  maxWidth: z.number().optional().default(2000).describe('圖片最大寬度'),
  maxHeight: z.number().optional().default(2000).describe('圖片最大高度')
});

// Output Schema: 辨識到的文字結果陣列
const PhotosOCROutputSchema = z.object({
  // Use the Zod schema object here
  results: z.array(SinglePhotoOCROutputSchema).describe('每張圖片的OCR結果'),
  totalProcessed: z.number().describe('總共處理的圖片數量'),
  successCount: z.number().describe('成功處理的圖片數量'),
  failedCount: z.number().describe('失敗的圖片數量'),
  menuImageCount: z.number().describe('文字長度超過20的圖片數量（判斷為包含菜單的圖片）'),
  information: z.string().describe('串接所有超過20字長度的文字內容（判斷為菜單內容）')
});

// 主要的 Flow 定義
export const photosOCRFlow = ai.defineFlow(
  {
    name: 'photosOCR',
    inputSchema: PhotosOCRInputSchema,
    outputSchema: PhotosOCROutputSchema,
  },
  async (params) => {
    // 實例化導入的 GoogleVisionService 類別 (它內部會使用 GooglePlacesPhotosService)
    const visionService = new GoogleVisionService(API); 
    
    try {
      const promises = params.photoReferences.map(photoReference => 
        visionService.processSinglePhoto(
          photoReference,
          params.maxWidth,
          params.maxHeight
        )
      );

      const results = await Promise.all(promises);
      
      const successCount = results.filter(result => result.success).length;
      const failedCount = results.length - successCount;

      const menuResults = results.filter(result => result.success && result.extractedText.length > 20);
      const menuTexts = menuResults.map(result => result.extractedText).join('\n\n');
      const menuImageCount = menuResults.length;

      return {
        results: results,
        totalProcessed: results.length,
        successCount: successCount,
        failedCount: failedCount,
        menuImageCount: menuImageCount,
        information: menuTexts
      };

    } catch (error: any) {
      console.error('Photos OCR Flow Error:', error);
      
      const failedResults = params.photoReferences.map(photoReference => ({
        success: false,
        extractedText: '',
        imageUrl: '',
        photoReference: photoReference,
        error: error.message
      }));

      return {
        results: failedResults,
        totalProcessed: params.photoReferences.length,
        successCount: 0,
        failedCount: params.photoReferences.length,
        menuImageCount: 0,
        information: ''
      };
    }
  }
);

// 普通 Cloud Function 版本
export const photosOCRFunction = functions.https.onCall(
  async (data: unknown, context) => {
    try {
      const params = PhotosOCRInputSchema.parse(data);
      // 實例化導入的 GoogleVisionService 類別
      const visionService = new GoogleVisionService(API); 
      
      const promises = params.photoReferences.map(photoReference => 
        visionService.processSinglePhoto(
          photoReference,
          params.maxWidth,
          params.maxHeight
        )
      );

      const results = await Promise.all(promises);
      
      const successCount = results.filter(result => result.success).length;
      const failedCount = results.length - successCount;

      const menuResults = results.filter(result => result.success && result.extractedText.length > 20);
      const menuTexts = menuResults.map(result => result.extractedText).join('\n\n');
      const menuImageCount = menuResults.length;

      return {
        results: results,
        totalProcessed: results.length,
        successCount: successCount,
        failedCount: failedCount,
        menuImageCount: menuImageCount,
        information: menuTexts
      };

    } catch (error: any) {
      console.error('Photos OCR Function Error:', error);
      
      return {
        results: [],
        totalProcessed: 0,
        successCount: 0,
        failedCount: 0,
        menuImageCount: 0,
        information: '',
        error: error.message
      };
    }
  }
);

// 導出類型定義供其他地方使用
export type PhotosOCRInput = z.infer<typeof PhotosOCRInputSchema>;
export type PhotosOCROutput = z.infer<typeof PhotosOCROutputSchema>;
// export type SinglePhotoOCROutput = z.infer<typeof SinglePhotoOCROutputSchema>; // 已從 google_vision_service 導出