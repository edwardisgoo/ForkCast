import { gemini15Flash, googleAI } from '@genkit-ai/googleai';
import { genkit } from 'genkit';

const ai = genkit({
  plugins: [googleAI()],
  model: gemini15Flash,
});

(async () => {
  const { text } = await ai.generate(
    'Invent a menu item for a pirate themed restaurant.'
  );
  console.log(text);
})();