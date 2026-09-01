// Firebase Admin initialization
// Credential strategy (see backend/.env.example):
//   Dev:  GOOGLE_APPLICATION_CREDENTIALS points to a service-account JSON
//         stored OUTSIDE the repository.
//   Prod: Application Default Credentials (ADC) via the hosting platform.
// NEVER place Firebase Admin credentials in Flutter or in the repo.
const admin = require('firebase-admin');

let initialized = false;

/**
 * Initializes Firebase Admin SDK.
 * Uses GOOGLE_APPLICATION_CREDENTIALS (picked up automatically by
 * google-auth-library) or ADC. Does NOT accept inline credentials.
 */
function initializeFirebaseAdmin() {
    if (initialized) return admin;

    const { env } = require('./env');

    admin.initializeApp({
        // Explicit project ID prevents accidentally talking to the wrong project.
        credential: admin.credential.applicationDefault(),
        projectId: env.firebaseProjectId,
    });

    initialized = true;
    return admin;
}

/**
 * Verifies a Firebase ID token and returns the decoded token.
 * The decoded token contains `uid`, `phone_number`, `exp`, etc.
 * Throws if the token is invalid, expired, or from another project.
 */
async function verifyIdToken(idToken) {
    const adminInstance = initializeFirebaseAdmin();
    return adminInstance.auth().verifyIdToken(idToken, true); // checkRevoked=true
}

module.exports = { initializeFirebaseAdmin, verifyIdToken };