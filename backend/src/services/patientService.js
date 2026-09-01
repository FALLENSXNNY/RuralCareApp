// Patient service — find-or-create and profile update keyed by verified
// Firebase UID. Duplicate prevention: lookup is by firebaseUid (unique index).
// Re-login returns the SAME record; a new record is created only for new UIDs.
const Patient = require('../models/Patient');

// Whitelist of patient-editable profile fields. Identity fields
// (firebaseUid, phone, role, isActive) are NEVER accept from the body.
const PROFILE_FIELDS = [
    'fullName',
    'age',
    'gender',
    'village',
    'district',
    'state',
    'bloodGroup',
    'allergies',
    'conditions',
];

/**
 * Finds an existing patient by Firebase UID, or creates one if none exists.
 * @param {string} firebaseUid - verified UID from the Firebase ID token
 * @param {string|null} phone - verified phone number from the token (E.164)
 * @returns {Promise<{patient: Object, isNewUser: boolean}>} the patient
 *   document (lean) plus whether this was a brand-new patient record
 *   (used by the app to route new users to onboarding).
 */
async function findOrCreateByUid(firebaseUid, phone) {
    // Detect whether a record already exists with a completed profile so the controller can report
    // `isNewUser` to the app (first-time users or users with uncompleted profiles go to registration).
    const existing = await Patient.findOne({ firebaseUid }).lean();
    const isNewUser = !existing || !existing.fullName || existing.fullName.trim() === '';

    const patient = await Patient.findOneAndUpdate(
        { firebaseUid },
        [
            {
                $set: {
                    lastLoginAt: '$$NOW',
                    // Only set phone on creation; if token phone differs, update it
                    // (e.g. user re-verified with a different number).
                    phone: { $ifNull: ['$phone', phone] },
                },
            },
        ],
        {
            new: true,
            upsert: true,
            setDefaultsOnInsert: true,
            projection: { __v: 0 },
        }
    ).lean();

    return { patient, isNewUser };
}

/**
 * Finds a patient by Firebase UID. Returns null if not found.
 */
async function findByUid(firebaseUid) {
    return Patient.findOne({ firebaseUid }).lean();
}

/**
 * Updates only the patient-editable profile fields for a UID.
 * SECURITY: only fields in PROFILE_FIELDS are applied. Identity fields
 * (firebaseUid, phone, role, isActive) from the body are never applied.
 *
 * @param {string} firebaseUid - verified UID from the Firebase ID token
 * @param {Object} updates - raw request body (possibly with extra keys)
 * @returns {Promise<Object>} the updated patient document (lean)
 */
async function updateProfile(firebaseUid, updates) {
    const clean = {};

    // Support 'name' alias from client JSON alongside canonical 'fullName'
    if (updates.name !== undefined && updates.fullName === undefined) {
        clean.fullName = updates.name;
    }

    for (const key of Object.keys(updates)) {
        if (PROFILE_FIELDS.includes(key)) {
            clean[key] = updates[key];
        }
    }

    if (Object.keys(clean).length === 0) {
        const err = new Error('No updatable profile fields were provided.');
        err.status = 400;
        throw err;
    }

    return Patient.findOneAndUpdate(
        { firebaseUid },
        { $set: clean },
        { new: true, runValidators: true, projection: { __v: 0 } }
    ).lean();
}

module.exports = { findOrCreateByUid, findByUid, updateProfile };