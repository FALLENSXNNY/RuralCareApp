// Mongoose model for Doctors
const mongoose = require('mongoose');

const doctorSchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true,
            index: true,
        },
        speciality: {
            type: String,
            required: true,
            trim: true,
            index: true,
        },
        qualification: {
            type: String,
            default: 'MBBS',
        },
        facilityId: {
            type: mongoose.Schema.Types.ObjectId,
            ref: 'Facility',
            default: null,
            index: true,
        },
        facilityName: {
            type: String,
            default: '',
        },
        experience: {
            type: String,
            default: '5 years',
        },
        availableSlots: {
            type: String,
            default: 'Mon–Fri: 10am–2pm',
        },
        acceptsOnline: {
            type: Boolean,
            default: false,
            index: true,
        },
        phone: {
            type: String,
            default: '',
        },
        isActive: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true,
        collection: 'doctors',
    }
);

doctorSchema.index({ name: 'text', speciality: 'text', facilityName: 'text' });

module.exports = mongoose.model('Doctor', doctorSchema);
