import { z } from "genkit";
import { ai } from "../config";
import { Recipe, RecipeSchema } from "../type";
import { gemini15Flash, imagen3 } from "@genkit-ai/vertexai";//原本的
//import { gemini15Flash002 } from "../config";
//import { recipieRetriever } from "../retriever";
import { gemini15Flash002 } from "@genkit-ai/vertexai";
const recipeGenerator = ai.definePrompt({
    model: gemini15Flash002,
    name: 'recipeGenerator',
    messages: `You are given an keyword and optional additional constrains. Your task is to generate a short sentence containing the keyword.

                Input:

                Keyword: {{suggestRecipe.title}}

                Constrains: {{ingredients}}

                Requirements:
                - Generate a short sentence containing the keyword.
                - Try to satisfy the additional constrains.

                Output format:
                - sentence: string, the generated short sentence.`,
    input: {
        schema: z.object({
            suggestRecipe: z.object({
                title: z.string()
            }),
            ingredients: z.string()
        })
    }
})



export const testFlow = ai.defineFlow({
    name: 'testFlow',
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
        return {
            recipe: customRecipe,
        };

    }
)