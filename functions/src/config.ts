import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  // TODO: add your firebase config here
  apiKey: "AIzaSyAcTJi85l_cSWCQgoT3bgFGDFMUncm3ao8",
  authDomain: "example-recipe-app-d465f.firebaseapp.com",
  projectId: "example-recipe-app-d465f",
  storageBucket: "example-recipe-app-d465f.firebasestorage.app",
  messagingSenderId: "752702754764",
  appId: "1:752702754764:web:73ff2191efe243d0ec9769",
  measurementId: "G-XPZ5QVVGSC"
};

export const getProjectId = () => firebaseConfig.projectId;

// enableFirebaseTelemetry({ projectId: getProjectId() });

export const ai = genkit({
  plugins: [
    vertexAI({
      projectId: getProjectId(),
      location: 'us-central1',
    }),
  ],
});
