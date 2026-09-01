const mongoose = require('mongoose');

const medicationSchema = new mongoose.Schema(
    {
        name: { type: String, required: true },
        dosage: { type: String, required: true },
        frequency: { type: String, required: true },
        duration: { type: String, required: true },
        instructions: { type: String, default: '' },
    },
    { _id: false }
);

const prescriptionSchema = new mongoose.Schema(
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
        medications: { type: [medicationSchema], default: [] },
        diagnosis: { type: String, default: '' },
        notes: { type: String, default: '' },
        prescribedDate: { type: Date, default: Date.now },
        validUntil: { type: Date },
    },
    {
        timestamps: true,
        collection: 'prescriptions',
    }
);

module.exports = mongoose.model('Prescription', prescriptionSchema);
