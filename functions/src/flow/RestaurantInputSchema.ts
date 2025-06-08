import { z } from "genkit";

// 定義 RestaurantInput schema
export const RestaurantInputSchema = z.object({
    id: z.string(),
    distance: z.number(),
    opening: z.boolean(),
    rating: z.number(),
    reviews: z.array(z.object({
        rating: z.number(),
        time: z.string(),
        text: z.string()
    })),
    photoInformation: z.string(),
    name: z.string(),
    summary: z.string(),
    types: z.string(),
    priceInformation: z.string(),
    extraInformation: z.string(),
    openingHours: z.array(
        z.object({
            day: z.number().min(0).max(6),
            start: z.object({ hour: z.number(), minute: z.number() }),
            end: z.object({ hour: z.number(), minute: z.number() })
        })
    ),
});