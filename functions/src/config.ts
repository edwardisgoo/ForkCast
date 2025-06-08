import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  apiKey: "AIzaSyDWLQvbNzLWjNxHVpV8AchD_4geD26YU6Y",
  authDomain: "forkcast-test-version.firebaseapp.com",
  projectId: "forkcast-test-version",
  storageBucket: "forkcast-test-version.firebasestorage.app",
  messagingSenderId: "268007894301",
  appId: "1:268007894301:web:989afe4c04e80b012745f4"
};
//export const API = "AIzaSyB9e1Gpeb7I0K68jyddur3ul5GGrjNoZnY";//陳光齊的API key
export const API = "AIzaSyCLCSWN_E1gJak2DJCySBhLdOJ8EkwM1cw";//梁皓翔的API key
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
