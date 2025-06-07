import { genkit } from 'genkit';
import { vertexAI } from '@genkit-ai/vertexai';

const firebaseConfig = {
  apiKey: "AIzaSyAwRaVbP50pOATcKGUqyG1q3yo0XDnR950",
  authDomain: "forkcast-c8d06.firebaseapp.com",
  projectId: "forkcast-c8d06",
  storageBucket: "forkcast-c8d06.firebasestorage.app",
  messagingSenderId: "343066555968",
  appId: "1:343066555968:web:4c27ab82925022d5c0d1a5"
};
export const API = "AIzaSyB9e1Gpeb7I0K68jyddur3ul5GGrjNoZnY";//陳光齊的API key
// export const API = "AIzaSyBKQqbW8A7wIbwRN6ebdelrpn-eV9SFtno";//梁皓翔的API key

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
