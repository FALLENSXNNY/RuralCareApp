const mongoose = require('mongoose');

const consultationSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Patient',
            required: true,
            index: true,
        },
        doctorName: { type: String, required: true },
        doctorSpecialty: { type: String, default: 'General Medicine' },
        facilityName: { type: String, required: true },
        type: {
            type: String,
            enum: ['TELECONSULTATION', 'IN_PERSON', 'ASSISTED'],
            default: 'IN_PERSON',
        },
        status: {
            type: String,
            enum: ['SCHEDULED', 'COMPLETED', 'CANCELLED'],
            default: 'COMPLETED',
        },
        consultationDate: { type: Date, default: Date.now },
        symptoms: { type: [String], default: [] },
        diagnosis: { type: String, default: '' },
        doctorNotes: { type: String, default: '' },
        followUpDate: { type: Date },
    },
    {
        timestamps: true,
        collection: 'consultations',
    }
);

module.exports = mongoose.model('Consultation', consultationSchema);
