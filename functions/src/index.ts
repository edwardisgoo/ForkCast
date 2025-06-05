import {onCallGenkit} from 'firebase-functions/https';

import './flow/findRestaurants';
import { findRestaurantsFlow } from './flow/findRestaurants';
export const findRestaurants = onCallGenkit(findRestaurantsFlow);


import './flow/detailGeneration';
import { detailGenerationFlow } from './flow/detailGeneration';
export const detailGeneration = onCallGenkit(detailGenerationFlow);


import './flow/actions/GooglePlacesNearbySearch';
import { placesNearbySearchFlow , nearbySearchFunction } from './flow/actions/GooglePlacesNearbySearch';
export const placesNearbySearch = onCallGenkit(placesNearbySearchFlow);
// export const placesNearbySearch = nearbySearchFunction;


import './flow/actions/GooglePlacesDetailsSearch';
import { placesDetailsSearchFlow , detailsSearchFunction} from './flow/actions/GooglePlacesDetailsSearch';
export const placesDetailsSearch = onCallGenkit(placesDetailsSearchFlow);
// export const placesDetailsSearch = detailsSearchFunction;

import './flow/actions/GooglePlacesGetRestaurantRaw';
import { placesGetRestaurantRawFlow} from './flow/actions/GooglePlacesGetRestaurantRaw';
export const placesGetRestaurantRaw = onCallGenkit(placesGetRestaurantRawFlow);


