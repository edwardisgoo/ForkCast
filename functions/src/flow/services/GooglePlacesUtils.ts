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

export function parseOpeningHours(periods?: OpeningHoursPeriod[]): TimePeriod[] {
  if (!periods || !Array.isArray(periods)) return [];
  
  return periods
    .filter(period => period.open && period.close) // Only include periods with both open and close
    .map(period => {
      // Pad with leading zeros to ensure 4-digit format (e.g., "900" becomes "0900")
      const openTime = period.open.time.padStart(4, '0');
      const closeTime = period.close?.time.padStart(4, '0') || '0000';
      
      return {
        start: {
          hour: parseInt(openTime.substring(0, 2)), // Extract hours (first 2 digits)
          minute: parseInt(openTime.substring(2, 4)) // Extract minutes (last 2 digits)
        },
        end: {
          hour: parseInt(closeTime.substring(0, 2)),
          minute: parseInt(closeTime.substring(2, 4))
        }
      };
    });
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