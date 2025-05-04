// hint: complete your retrieveRecipeFlow here
import { z } from "genkit";
import { ai } from "../config";
import { Recipe } from "../type";//, RecipeSchema
//import { gemini15Flash, imagen3 } from "@genkit-ai/vertexai";
import { recipieRetriever } from "../retriever";

export const retrieveRecipeFlow = ai.defineFlow({
    name: 'retrieveRecipeFlow',
    inputSchema: z.string()
},
    async (input) => {

        const recipes: Recipe[] = await ai.run(
            'Retrieve matching ingredients',
            async () => {
                try{
                    const docs = await ai.retrieve({
                        retriever: recipieRetriever,
                        query: input,
                        options: {
                            limit: 5,
                        },
                    });
                    return docs.map((doc) => {
                        const data = doc.toJSON();
                        console.log(data);
                        const recipe : Recipe = {
                            title: '',
                            directions: '',
                            ingredients: '',
                            ...data.metadata,
                        };
                        delete recipe.ingredient_embedding;
                        recipe.ingredients = data.content[0].text!
                        return recipe;
                    });
                }
                catch(error) {
                    console.log(error);
                    return [];
                }
            },
        );

        return {recipes:recipes};

    }
)