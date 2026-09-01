const mongoose = require('mongoose');

const referralSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Patient',
            required: true,
            index: true,
        },
        fromFacility: { type: String, required: true },
        toFacility: { type: String, required: true },
        referringDoctor: { type: String, required: true },
        specialtyRequired: { type: String, required: true },
        reason: { type: String, required: true },
        priority: {
            type: String,
            enum: ['ROUTINE', 'URGENT', 'EMERGENCY'],
            default: 'ROUTINE',
        },
        status: {
            type: String,
            enum: ['INITIATED', 'ACCEPTED', 'APPOINTMENT_SCHEDULED', 'COMPLETED', 'CANCELLED'],
            default: 'INITIATED',
        },
        referralDate: { type: Date, default: Date.now },
        appointmentDate: { type: Date },
        transportAssistance: { type: Boolean, default: false },
        notes: { type: String, default: '' },
    },
    {
        timestamps: true,
        collection: 'referrals',
    }
);

module.exports = mongoose.model('Referral', referralSchema);
