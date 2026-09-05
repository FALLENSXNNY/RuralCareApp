// Environment configuration loader
// Reads backend/.env — NEVER commit the real .env file.
require('dotenv').config();

const required = (name) => {
    const value = process.env[name];
    if (!value) {
        // Fail fast at startup for missing critical configuration.
        throw new Error(
            `Missing required environment variable: ${name}. ` +
            'Copy backend/.env.example to backend/.env and fill in real values.'
        );
    }
    return value;
};

const env = {
    port: parseInt(process.env.PORT || '3000', 10),
    nodeEnv: process.env.NODE_ENV || 'development',
    isProduction: process.env.NODE_ENV === 'production',

    // MongoDB Atlas
    mongoUri: process.env.MONGODB_URI,

    // Firebase Admin
    firebaseProjectId: process.env.FIREBASE_PROJECT_ID,
    // Path to service-account JSON stored OUTSIDE the repo (dev),
    // or unset when using Application Default Credentials (production).
    googleApplicationCredentials: process.env.GOOGLE_APPLICATION_CREDENTIALS,

    // Gemini
    geminiApiKey: process.env.GEMINI_API_KEY,

    // Google Maps Platform (Places & Directions) — never exposed to Flutter
    googleMapsApiKey: process.env.GOOGLE_MAPS_API_KEY || process.env.GOOGLE_MAP_API_KEY || '',
};

// Validate critical vars only when actually connecting to real services.
// Tests run without them (mocked Firebase/Mongo).
const validateForRuntime = () => {
    if (!env.mongoUri) {
        throw new Error(
            'MONGODB_URI is required. See backend/.env.example.'
        );
    }
    if (!env.firebaseProjectId) {
        throw new Error(
            'FIREBASE_PROJECT_ID is required. See backend/.env.example.'
        );
    }
};

module.exports = { env, required, validateForRuntime };