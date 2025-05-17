import {onCallGenkit} from 'firebase-functions/https';

// TODO: export your functions
// import './flow/customRecipe';//引用 customRecipe.ts

// import { customRecipeFlow } from './flow/customRecipe';//要在這裡宣告才會deploy上去 且命名也在這
// export const customRecipe = onCallGenkit(customRecipeFlow);//要在這裡宣告才會deploy上去 且命名也在這
//import './flow/retrieveRecipe';//引用 retrieveRecipe.ts
//import { retrieveRecipeFlow } from './flow/retrieveRecipe';
//export const retrieveRecipe = onCallGenkit(retrieveRecipeFlow);
//import { testFlow } from './flow/testFlow';
//export const test = onCallGenkit(testFlow);
import './flow/findRestaurants';
import { findRestaurantsFlow } from './flow/findRestaurants';
export const findRestaurants = onCallGenkit(findRestaurantsFlow);
import './flow/detailGeneration';
import { detailGenerationFlow } from './flow/detailGeneration';
export const detailGeneration = onCallGenkit(detailGenerationFlow);

