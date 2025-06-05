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
