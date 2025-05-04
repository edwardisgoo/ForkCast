import {onCallGenkit} from 'firebase-functions/https';

// TODO: export your functions
import './flow/customRecipe';//引用 customRecipe.ts
import './flow/retrieveRecipe';//引用 retrieveRecipe.ts
import { customRecipeFlow } from './flow/customRecipe';//要在這裡宣告才會deploy上去 且命名也在這
import { retrieveRecipeFlow } from './flow/retrieveRecipe';
export const customRecipe = onCallGenkit(customRecipeFlow);//要在這裡宣告才會deploy上去 且命名也在這
export const retrieveRecipe = onCallGenkit(retrieveRecipeFlow);

