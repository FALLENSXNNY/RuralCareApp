// Mongoose model for Healthcare Facilities
const mongoose = require('mongoose');

const facilitySchema = new mongoose.Schema(
    {
        name: {
            type: String,
            required: true,
            trim: true,
            index: true,
        },
        type: {
            type: String,
            required: true,
            enum: ['Primary Health Centre', 'Community Health Centre', 'District Hospital', 'Sub Centre', 'Clinic', 'Hospital'],
            index: true,
        },
        address: {
            type: String,
            default: '',
        },
        district: {
            type: String,
            default: 'Satara',
            index: true,
        },
        state: {
            type: String,
            default: 'Maharashtra',
        },
        location: {
            type: {
                type: String,
                enum: ['Point'],
                default: 'Point',
            },
            coordinates: {
                type: [Number], // [longitude, latitude]
                default: [74.0, 17.68],
            },
        },
        distance: {
            type: String,
            default: '',
        },
        phone: {
            type: String,
            default: '',
        },
        hours: {
            type: String,
            default: 'Mon–Sat: 8am–4pm',
        },
        isOpen: {
            type: Boolean,
            default: true,
        },
        services: {
            type: [String],
            default: [],
        },
        emergencyCapable: {
            type: Boolean,
            default: false,
        },
        beds: {
            type: Number,
            default: 0,
        },
        isActive: {
            type: Boolean,
            default: true,
        },
    },
    {
        timestamps: true,
        collection: 'facilities',
    }
);

facilitySchema.index({ location: '2dsphere' });
facilitySchema.index({ name: 'text', address: 'text', services: 'text' });

module.exports = mongoose.model('Facility', facilitySchema);
