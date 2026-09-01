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

    let credential;
    if (process.env.FIREBASE_SERVICE_ACCOUNT) {
        try {
            let raw = process.env.FIREBASE_SERVICE_ACCOUNT.trim();
            if (!raw.startsWith('{')) {
                // If base64 encoded
                raw = Buffer.from(raw, 'base64').toString('utf8');
            }
            const serviceAccount = JSON.parse(raw);
            credential = admin.credential.cert(serviceAccount);
            console.log('[firebase] Admin SDK initialized using FIREBASE_SERVICE_ACCOUNT');
        } catch (err) {
            console.warn('[firebase] Could not parse FIREBASE_SERVICE_ACCOUNT JSON, falling back to ADC:', err.message);
            credential = admin.credential.applicationDefault();
        }
    } else {
        credential = admin.credential.applicationDefault();
    }

    admin.initializeApp({
        credential,
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