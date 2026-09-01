const mongoose = require('mongoose');

const testResultSchema = new mongoose.Schema(
    {
        parameter: { type: String, required: true },
        value: { type: String, required: true },
        unit: { type: String, default: '' },
        referenceRange: { type: String, default: '' },
        isAbnormal: { type: Boolean, default: false },
    },
    { _id: false }
);

const diagnosticSchema = new mongoose.Schema(
    {
        patientId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Patient',
            required: true,
            index: true,
        },
        testName: { type: String, required: true },
        testCategory: { type: String, default: 'General' },
        facilityName: { type: String, required: true },
        orderedBy: { type: String, default: 'Medical Officer' },
        status: {
            type: String,
            enum: ['ORDERED', 'IN_PROGRESS', 'COMPLETED'],
            default: 'COMPLETED',
        },
        reportDate: { type: Date, default: Date.now },
        resultSummary: { type: String, default: '' },
        results: { type: [testResultSchema], default: [] },
    },
    {
        timestamps: true,
        collection: 'diagnostics',
    }
);

module.exports = mongoose.model('Diagnostic', diagnosticSchema);
