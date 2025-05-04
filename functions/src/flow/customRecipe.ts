import { z } from "genkit";
import { ai } from "../config";
import { Recipe, RecipeSchema } from "../type";
import { gemini15Flash, imagen3 } from "@genkit-ai/vertexai";
//import { recipieRetriever } from "../retriever";

const recipeGenerator = ai.definePrompt({
    model: gemini15Flash,
    name: 'recipeGenerator',
    messages: `You are given an keyword, try to generate a sentence containing the keyword.

                Input:

                Keyword: {{suggestRecipe.title}}

                Additional constrains: {{ingredients}}

                Requirements:
                - Generate a sentence containing the keyword and following the additional constrains.

                Output format:
                - title: string, the generated sentence`,
    input: {
        schema: z.object({
            suggestRecipe: z.object({
                title: z.string()
            }),
            ingredients: z.string()
        })
    }
})


export const customRecipeFlow = ai.defineFlow({
    name: 'customRecipeFlow',
    //inputSchema: z.string(),
    //hint: change to this inputSchema for lab */
    inputSchema: z.object({
        suggestRecipe: RecipeSchema,
        ingredients: z.string()
    }),
},
    async (input) => {

        const suggestRecipe: Recipe = input.suggestRecipe;
        const response = await recipeGenerator(

            {
                suggestRecipe: suggestRecipe,
                ingredients: input.ingredients
            });

        const customRecipe: Recipe | null = response?.output;
        if (!customRecipe) {
            throw new Error("Recipe not found cause a null");
        }
        //return customRecipe;

        /* hint: change to this return format for lab */
        return {
            recipe: customRecipe
        };

    }
)