import {onCallGenkit} from 'firebase-functions/https';

import './flow/findRestaurants';
import { findRestaurantsFlow } from './flow/findRestaurants';
export const findRestaurants = onCallGenkit(findRestaurantsFlow);


import './flow/detailGeneration';
import { detailGenerationFlow } from './flow/detailGeneration';
export const detailGeneration = onCallGenkit(detailGenerationFlow);


import './flow/actions/GooglePlacesNearbySearch';
import { placesNearbySearchFlow } from './flow/actions/GooglePlacesNearbySearch';
export const placesNearbySearch = onCallGenkit(placesNearbySearchFlow);
// export const placesNearbySearch = nearbySearchFunction;


import './flow/actions/GooglePlacesDetailsSearch';
import { placesDetailsSearchFlow } from './flow/actions/GooglePlacesDetailsSearch';
export const placesDetailsSearch = onCallGenkit(placesDetailsSearchFlow);
// export const placesDetailsSearch = detailsSearchFunction;

import './flow/actions/GooglePlacesGetRestaurantRaw';
import { placesGetRestaurantRawFlow} from './flow/actions/GooglePlacesGetRestaurantRaw';
export const placesGetRestaurantRaw = onCallGenkit(placesGetRestaurantRawFlow);

import './flow/actions/GetImageText';
import { photosOCRFlow } from './flow/actions/GetImageText';
export const photosOCR = onCallGenkit(photosOCRFlow);

import './flow/queryToRestaurantInput';
import { restaurantQueryFlow } from './flow/queryToRestaurantInput';
export const restaurantQuery = onCallGenkit(restaurantQueryFlow);

import './flow/queryToFinal';
import { restaurantRecommendationFlow } from './flow/queryToFinal';
export const restaurantRecommendation = onCallGenkit(restaurantRecommendationFlow);

import './flow/queryToFinal_test';
import { restaurantRecommendationFlowMock } from './flow/queryToFinal_test';
export const restaurantRecommendationMock = onCallGenkit(restaurantRecommendationFlowMock);