import { ai, API } from "../config";
import { z } from 'zod';
import * as functions from 'firebase-functions';

// 輸入 Schema：Google Maps API 回傳的 photos string array（使用固定的 API key）
const PhotosOCRInputSchema = z.object({
  photoReferences: z.array(z.string()).describe('Google Maps API 回傳的 photo reference string 陣列'),
  maxWidth: z.number().optional().default(2000).describe('圖片最大寬度'),
  maxHeight: z.number().optional().default(2000).describe('圖片最大高度')
});

// 單一圖片的輸出 Schema
const SinglePhotoOCROutputSchema = z.object({
  success: z.boolean().describe('是否成功辨識'),
  extractedText: z.string().describe('從圖片中辨識到的文字'),
  confidence: z.number().optional().describe('辨識信心度'),
  imageUrl: z.string().describe('實際圖片 URL'),
  photoReference: z.string().describe('對應的 photo reference'),
  error: z.string().optional().describe('錯誤訊息')
});

// 輸出 Schema：辨識到的文字結果陣列
const PhotosOCROutputSchema = z.object({
  results: z.array(SinglePhotoOCROutputSchema).describe('每張圖片的OCR結果'),
  totalProcessed: z.number().describe('總共處理的圖片數量'),
  successCount: z.number().describe('成功處理的圖片數量'),
  failedCount: z.number().describe('失敗的圖片數量'),
  menuImageCount: z.number().describe('文字長度超過20的圖片數量（判斷為包含菜單的圖片）'),
  information: z.string().describe('串接所有超過20字長度的文字內容（判斷為菜單內容）')
});


// Google Vision API OCR 服務類別
class GoogleVisionService {
  private apiKey: string;

  constructor(apiKey: string) {
    this.apiKey = apiKey;
  }

  // 從 Google Maps photo reference 獲取圖片
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
      
      if (response.ok) {
        return photoUrl;
      }
      
      throw new Error(`HTTP ${response.status}: ${response.statusText}`);
    } catch (error: any) {
      throw new Error(`無法獲取圖片: ${error.message}`);
    }
  }

  // 使用 Google Vision API 進行 OCR
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
            languageHints: ['zh-TW', 'zh-CN', 'en'] // 支援繁體中文、簡體中文、英文
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

      // 第一個結果通常是完整的文字
      const fullText = annotations[0].description || '';
      const confidence = annotations[0].boundingPoly ? 1.0 : 0.5; // 簡化的信心度計算

      return {
        text: fullText.trim(),
        confidence: confidence
      };

    } catch (error: any) {
      throw new Error(`OCR 處理失敗: ${error.message}`);
    }
  }

  // 處理單一圖片的 OCR
  async processSinglePhoto(
    photoReference: string,
    maxWidth: number,
    maxHeight: number
  ): Promise<z.infer<typeof SinglePhotoOCROutputSchema>> {
    try {
      // 1. 從 photo reference 獲取圖片 URL
      const imageUrl = await this.getPhotoFromReference(
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

// 主要的 Flow 定義
export const photosOCRFlow = ai.defineFlow(
  {
    name: 'photosOCR',
    inputSchema: PhotosOCRInputSchema,
    outputSchema: PhotosOCROutputSchema,
  },
  async (params) => {
    const visionService = new GoogleVisionService(API); // 使用 config 中的 API key
    
    try {
      // 並行處理所有圖片
      const promises = params.photoReferences.map(photoReference => 
        visionService.processSinglePhoto(
          photoReference,
          params.maxWidth,
          params.maxHeight
        )
      );

      const results = await Promise.all(promises);
      
      // 統計處理結果
      const successCount = results.filter(result => result.success).length;
      const failedCount = results.length - successCount;

      // 篩選並串接所有超過20字長度的文字內容（判斷為菜單內容）
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
      
      // 如果整個流程失敗，返回所有失敗的結果
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
      const visionService = new GoogleVisionService(API); // 使用 config 中的 API key
      
      // 並行處理所有圖片
      const promises = params.photoReferences.map(photoReference => 
        visionService.processSinglePhoto(
          photoReference,
          params.maxWidth,
          params.maxHeight
        )
      );

      const results = await Promise.all(promises);
      
      // 統計處理結果
      const successCount = results.filter(result => result.success).length;
      const failedCount = results.length - successCount;

      // 篩選並串接所有超過20字長度的文字內容（判斷為菜單內容）
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
      
      // 如果解析參數失敗，返回錯誤
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
export type SinglePhotoOCROutput = z.infer<typeof SinglePhotoOCROutputSchema>;