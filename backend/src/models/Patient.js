// Patient model — associates a Firebase authenticated user with a patient
// profile. Identity (firebaseUid, phone) is derived ONLY from the verified
// Firebase ID token. Profile fields (Phase 3) are set/updated by the patient
// and are never trusted for identity lookups.
const mongoose = require('mongoose');

const patientSchema = new mongoose.Schema(
    {
        // Firebase UID — the authoritative identity key.
        // Derived from the verified Firebase ID token, NEVER from request bodies.
        firebaseUid: {
            type: String,
            required: true,
            unique: true,
            index: true,
        },

        // Phone number from the verified Firebase token (E.164 format, e.g. +919876543210)
        phone: {
            type: String,
            required: true,
        },

        // ── Patient profile (Phase 3) ──────────────────────────────────────
        // These are the patient's own editable profile fields. They are
        // stored on the patient record, keyed by firebaseUid. Defaults keep
        // existing patients (created before Phase 3) valid.
        fullName: {
            type: String,
            default: '',
            trim: true,
        },

        age: {
            type: Number,
            default: 0,
            min: 0,
            max: 150,
        },

        gender: {
            type: String,
            enum: ['Female', 'Male', 'Other', ''],
            default: '',
        },

        village: {
            type: String,
            default: '',
            trim: true,
        },

        district: {
            type: String,
            default: '',
            trim: true,
        },

        state: {
            type: String,
            default: '',
            trim: true,
        },

        bloodGroup: {
            type: String,
            enum: ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-', "Don't Know", ''],
            default: '',
        },

        allergies: {
            type: [String],
            default: [],
        },

        conditions: {
            type: [String],
            default: [],
        },

        // Role is fixed server-side. Clients cannot set or change it.
        role: {
            type: String,
            enum: ['PATIENT'],
            default: 'PATIENT',
        },

        isActive: {
            type: Boolean,
            default: true,
        },

        lastLoginAt: {
            type: Date,
            default: Date.now,
        },
    },
    {
        timestamps: true, // adds createdAt / updatedAt
        versionKey: false,
    }
);

module.exports = mongoose.model('Patient', patientSchema);