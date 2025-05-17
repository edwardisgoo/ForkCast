import { z } from "zod";

export const RecipeSchema = z.object({
  title: z.string(),
});
export const RestaurantSchema = z.object({
  title: z.string(),
});

export type Recipe = z.infer<typeof RecipeSchema>;