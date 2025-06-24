

// Initialize Firebase Admin SDK

import { initializeApp } from "firebase-admin/app";
import { getAuth } from "firebase-admin/auth";

// You should replace this with your own service account key or use environment variables
const app = initializeApp();

export const auth = getAuth(app);
