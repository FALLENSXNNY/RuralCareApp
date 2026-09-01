// Facility Service — clinical facility and doctor lookups
const Facility = require('../models/Facility');
const Doctor = require('../models/Doctor');

/**
 * Seeds starter facilities and doctors into MongoDB Atlas if none exist.
 */
async function seedStarterFacilitiesIfEmpty() {
    try {
        const facilityCount = await Facility.countDocuments();
        if (facilityCount === 0) {
            const f1 = await Facility.create({
                name: 'PHC Koregaon',
                type: 'Primary Health Centre',
                address: 'Main Road, Koregaon, Satara',
                district: 'Satara',
                state: 'Maharashtra',
                distance: '0.8 km',
                phone: '02163-123456',
                hours: 'Mon–Sat: 8am–4pm',
                isOpen: true,
                emergencyCapable: false,
                beds: 6,
                services: ['OPD', 'Maternity', 'Immunisation', 'Lab Tests'],
                location: { type: 'Point', coordinates: [74.1756, 17.7022] },
            });

            const f2 = await Facility.create({
                name: 'CHC Wai',
                type: 'Community Health Centre',
                address: 'Hospital Road, Wai, Satara',
                district: 'Satara',
                state: 'Maharashtra',
                distance: '12 km',
                phone: '02167-234567',
                hours: 'Open 24 hours',
                isOpen: true,
                emergencyCapable: true,
                beds: 30,
                services: ['Emergency', 'Surgery', 'OPD', 'X-Ray', 'Lab', 'Pharmacy'],
                location: { type: 'Point', coordinates: [73.8926, 17.9493] },
            });

            const f3 = await Facility.create({
                name: 'District Hospital Satara',
                type: 'District Hospital',
                address: 'Civil Hospital Road, Satara',
                district: 'Satara',
                state: 'Maharashtra',
                distance: '38 km',
                phone: '02162-234000',
                hours: 'Open 24 hours',
                isOpen: true,
                emergencyCapable: true,
                beds: 300,
                services: [
                    'Emergency',
                    'ICU',
                    'Surgery',
                    'Maternity',
                    'Paediatrics',
                    'Gynaecology',
                    'Orthopaedics',
                    'Eye',
                    'ENT',
                    'Lab',
                    'X-Ray',
                    'CT Scan',
                ],
                location: { type: 'Point', coordinates: [73.9926, 17.6805] },
            });

            await Doctor.create([
                {
                    name: 'Dr. Rajesh Kumar',
                    speciality: 'General Physician',
                    qualification: 'MBBS, MD',
                    facilityId: f1._id,
                    facilityName: 'PHC Koregaon',
                    experience: '12 years',
                    availableSlots: 'Today, 10am–1pm',
                    acceptsOnline: true,
                    phone: '02163-123456',
                },
                {
                    name: 'Dr. Priya Sharma',
                    speciality: 'Gynaecologist',
                    qualification: 'MBBS, MS (OBG)',
                    facilityId: f2._id,
                    facilityName: 'CHC Wai',
                    experience: '8 years',
                    availableSlots: 'Tomorrow, 9am–12pm',
                    acceptsOnline: false,
                    phone: '02167-234567',
                },
                {
                    name: 'Dr. Amit Patil',
                    speciality: 'Paediatrician',
                    qualification: 'MBBS, DCH',
                    facilityId: f3._id,
                    facilityName: 'District Hospital Satara',
                    experience: '15 years',
                    availableSlots: '30 Aug, 2pm–5pm',
                    acceptsOnline: true,
                    phone: '02162-234000',
                },
            ]);
        }
    } catch (err) {
        console.error('[facilityService] Seeding error:', err.message);
    }
}

/**
 * Maps a Facility doc to API JSON format
 */
function toFacilityJson(f) {
    return {
        id: f._id.toString(),
        name: f.name,
        type: f.type,
        address: f.address,
        distance: f.distance || 'Near you',
        phone: f.phone || '',
        hours: f.hours || 'Open daily',
        isOpen: f.isOpen !== false,
        services: f.services || [],
        emergencyCapable: f.emergencyCapable === true,
        beds: f.beds || 0,
    };
}

/**
 * Maps a Doctor doc to API JSON format
 */
function toDoctorJson(d) {
    return {
        id: d._id.toString(),
        name: d.name,
        speciality: d.speciality,
        qualification: d.qualification || 'MBBS',
        facility: d.facilityName || (d.facilityId ? d.facilityId.name : 'Health Centre'),
        experience: d.experience || '5 years',
        availableSlots: d.availableSlots || 'Consultation available',
        acceptsOnline: d.acceptsOnline === true,
        phone: d.phone || '',
    };
}

/**
 * Retrieves facilities with optional search and type filtering.
 */
async function getFacilities(query = {}) {
    await seedStarterFacilitiesIfEmpty();

    const filter = { isActive: true };

    if (query.type && query.type !== 'All') {
        filter.type = new RegExp(query.type, 'i');
    }

    if (query.search && query.search.trim() !== '') {
        const regex = new RegExp(query.search.trim(), 'i');
        filter.$or = [
            { name: regex },
            { address: regex },
            { type: regex },
            { services: regex },
        ];
    }

    const facilities = await Facility.find(filter).sort({ name: 1 }).lean();
    return facilities.map(toFacilityJson);
}

/**
 * Retrieves a facility by ID.
 */
async function getFacilityById(id) {
    await seedStarterFacilitiesIfEmpty();
    const facility = await Facility.findOne({ _id: id, isActive: true }).lean();
    if (!facility) return null;
    return toFacilityJson(facility);
}

/**
 * Retrieves doctors with optional search, speciality, or online filtering.
 */
async function getDoctors(query = {}) {
    await seedStarterFacilitiesIfEmpty();

    const filter = { isActive: true };

    if (query.speciality && query.speciality.trim() !== '') {
        filter.speciality = new RegExp(query.speciality.trim(), 'i');
    }

    if (query.acceptsOnline !== undefined) {
        filter.acceptsOnline = query.acceptsOnline === 'true' || query.acceptsOnline === true;
    }

    if (query.search && query.search.trim() !== '') {
        const regex = new RegExp(query.search.trim(), 'i');
        filter.$or = [
            { name: regex },
            { speciality: regex },
            { facilityName: regex },
            { qualification: regex },
        ];
    }

    const doctors = await Doctor.find(filter).sort({ name: 1 }).lean();
    return doctors.map(toDoctorJson);
}

/**
 * Retrieves a doctor by ID.
 */
async function getDoctorById(id) {
    await seedStarterFacilitiesIfEmpty();
    const doctor = await Doctor.findOne({ _id: id, isActive: true }).lean();
    if (!doctor) return null;
    return toDoctorJson(doctor);
}

module.exports = {
    seedStarterFacilitiesIfEmpty,
    getFacilities,
    getFacilityById,
    getDoctors,
    getDoctorById,
    toFacilityJson,
    toDoctorJson,
};
