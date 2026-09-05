// Patient controller — returns/updates the authenticated patient's own record.
// SECURITY: identity comes from req.uid (verified Firebase token).
// A patientId supplied by the client is ignored entirely.
const patientService = require('../services/patientService');

// Maps a MongoDB patient document to the API shape consumed by the Flutter
// Patient model. Identity fields (firebaseUid) are included for the client's
// local state cache, but the backend still derives identity from the token.
function toPatientJson(patient) {
    return {
        id: patient._id.toString(),
        firebaseUid: patient.firebaseUid,
        name: patient.fullName || '',
        phone: patient.phone || '',
        age: patient.age || 0,
        gender: patient.gender || '',
        isPregnant: Boolean(patient.isPregnant),
        gestationalWeek: patient.gestationalWeek !== undefined ? patient.gestationalWeek : null,
        edd: patient.edd || null,
        village: patient.village || '',
        district: patient.district || '',
        state: patient.state || '',
        bloodGroup: patient.bloodGroup || '',
        emergencyContactName: patient.emergencyContactName || '',
        emergencyContactPhone: patient.emergencyContactPhone || '',
        abhaId: patient.abhaId || '',
        preferredLanguage: patient.preferredLanguage || 'en',
        allergies: patient.allergies || [],
        conditions: patient.conditions || [],
    };
}

/**
 * GET /api/v1/patients/me
 * Headers: Authorization: Bearer <firebase-id-token>
 * Response: { patient: { id, firebaseUid, name, phone, age, gender,
 *   village, district, state, bloodGroup, allergies, conditions } }
 */
async function getMe(req, res, next) {
    try {
        const patient = await patientService.findByUid(req.uid);

        if (!patient || patient.isActive === false) {
            return res.status(403).json({
                error: 'FORBIDDEN',
                message: 'This account is not active.',
            });
        }

        return res.status(200).json({
            patient: toPatientJson(patient),
        });
    } catch (err) {
        return next(err);
    }
}

/**
 * PUT /api/v1/patients/me
 * Headers: Authorization: Bearer <firebase-id-token>
 * Body: { fullName?, age?, gender?, village?, district?, state?,
 *   bloodGroup?, allergies?, conditions? }
 * Response: { patient: { ...updated profile } }
 * SECURITY: Only whitelisted profile fields are applied. Identity fields
 * (id, phone, firebaseUid, role) in the body are ignored.
 */
async function updateMe(req, res, next) {
    try {
        const patient = await patientService.updateProfile(req.uid, req.body);

        if (!patient || patient.isActive === false) {
            return res.status(403).json({
                error: 'FORBIDDEN',
                message: 'This account is not active.',
            });
        }

        return res.status(200).json({
            patient: toPatientJson(patient),
        });
    } catch (err) {
        return next(err);
    }
}

module.exports = { getMe, updateMe };