// Authentication middleware — verifies Firebase ID tokens.
// SECURITY: identity is derived ONLY from the verified token.
// This middleware NEVER trusts uid/phone/patientId from headers or body.
const { verifyIdToken } = require('../config/firebase');

/**
 * Express middleware. Expects: Authorization: Bearer <firebase-id-token>
 * On success attaches: req.uid (Firebase UID), req.phoneNumber, req.firebaseToken
 * On failure responds 401 with a controlled error (no stack traces).
 */
async function authenticate(req, res, next) {
    try {
        const header = req.headers.authorization || '';

        if (!header.startsWith('Bearer ')) {
            return res.status(401).json({
                error: 'UNAUTHORIZED',
                message: 'Missing or malformed Authorization header.',
            });
        }

        const idToken = header.slice('Bearer '.length).trim();
        if (!idToken) {
            return res.status(401).json({
                error: 'UNAUTHORIZED',
                message: 'Missing authentication token.',
            });
        }

        // Verify with Firebase Admin (checks signature, expiry, revocation, audience)
        let decoded;
        try {
            decoded = await verifyIdToken(idToken);
        } catch (err) {
            // Token invalid/expired/revoked/wrong project — do not leak details.
            return res.status(401).json({
                error: 'UNAUTHORIZED',
                message: 'Invalid or expired authentication token.',
            });
        }

        if (!decoded || !decoded.uid) {
            return res.status(401).json({
                error: 'UNAUTHORIZED',
                message: 'Invalid authentication token.',
            });
        }

        // Attach verified identity to the request.
        req.uid = decoded.uid;
        req.phoneNumber = decoded.phone_number || null;
        req.firebaseToken = decoded;

        return next();
    } catch (err) {
        // Unexpected failure — controlled 401, no internal details.
        return res.status(401).json({
            error: 'UNAUTHORIZED',
            message: 'Authentication failed.',
        });
    }
}

module.exports = { authenticate };