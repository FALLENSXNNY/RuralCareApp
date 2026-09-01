// Auth controller — exchanges a verified Firebase ID token for a patient session.
// SECURITY: the patient identity comes from req.uid (set by the authenticate
// middleware after Firebase token verification). Values in the request body
// are NEVER used to determine identity.
const patientService = require('../services/patientService');

/**
 * POST /api/v1/auth/session
 * Headers: Authorization: Bearer <firebase-id-token>
 * Response: { isNewUser, patient: { id, firebaseUid, phone, role, createdAt, updatedAt } }
 */
async function createSession(req, res, next) {
    try {
        // req.uid and req.phoneNumber come from the VERIFIED Firebase token.
        const { patient, isNewUser } = await patientService.findOrCreateByUid(
            req.uid,
            req.phoneNumber
        );

        if (!patient || patient.isActive === false) {
            return res.status(403).json({
                error: 'FORBIDDEN',
                message: 'This account is not active.',
            });
        }

        return res.status(200).json({
            // True when this UID had no patient record — the app routes new
            // users to the registration/onboarding flow.
            isNewUser: isNewUser === true,
            patient: {
                id: patient._id.toString(),
                firebaseUid: patient.firebaseUid,
                name: patient.fullName || '',
                phone: patient.phone || '',
                age: patient.age,
                gender: patient.gender,
                village: patient.village,
                district: patient.district,
                state: patient.state,
                bloodGroup: patient.bloodGroup,
                allergies: patient.allergies || [],
                conditions: patient.conditions || [],
                role: patient.role,
                createdAt: patient.createdAt,
                updatedAt: patient.updatedAt,
            },
        });
    } catch (err) {
        return next(err);
    }
}

module.exports = { createSession };