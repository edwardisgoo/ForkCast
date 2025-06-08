import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  apiKey: "AIzaSyAwRaVbP50pOATcKGUqyG1q3yo0XDnR950",
  authDomain: "forkcast-c8d06.firebaseapp.com",
  projectId: "forkcast-c8d06",
  storageBucket: "forkcast-c8d06.firebasestorage.app",
  messagingSenderId: "343066555968",
  appId: "1:343066555968:web:c1ff5f4a6ef2693ac0d1a5"
};
export const API = "AIzaSyB9e1Gpeb7I0K68jyddur3ul5GGrjNoZnY";//陳光齊的API key
// export const API = "AIzaSyCLCSWN_E1gJak2DJCySBhLdOJ8EkwM1cw";//梁皓翔的API key
// const API = process.env.GOOGLE_PLACES_API_KEY; //deploy上firebase要用的

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
