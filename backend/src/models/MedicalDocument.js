const mongoose = require('mongoose');

const documentTypeEnum = [
    'Prescription',
    'Lab Report',
    'Discharge Summary',
    'X-Ray / Scan',
    'Insurance',
    'Medical Report',
    'Other',
];

const medicalDocumentSchema = new mongoose.Schema(
    {
        patientId: {
            type: String,
            required: true,
            index: true,
        },
        title: {
            type: String,
            required: true,
            trim: true,
            maxlength: 150,
        },
        documentType: {
            type: String,
            required: true,
            enum: documentTypeEnum,
            default: 'Other',
        },
        filePath: {
            type: String,
            default: null,
        },
        fileUrl: {
            type: String,
            default: null,
        },
        fileData: {
            type: String,
            default: null, // Base64 encoded image or document string
        },
        mimeType: {
            type: String,
            default: 'image/jpeg',
        },
        fileSize: {
            type: Number,
            default: 0,
        },
        notes: {
            type: String,
            default: '',
            maxlength: 500,
        },
        uploadedAt: {
            type: Date,
            default: Date.now,
            index: true,
        },
    },
    {
        timestamps: true,
    }
);

medicalDocumentSchema.methods.toJSON = function () {
    const obj = this.toObject();
    obj.id = obj._id ? obj._id.toString() : obj.id;
    delete obj._id;
    delete obj.__v;
    return obj;
};

module.exports = mongoose.model('MedicalDocument', medicalDocumentSchema);
