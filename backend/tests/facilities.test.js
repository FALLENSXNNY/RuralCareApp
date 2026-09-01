// Unit tests for Facility & Doctor endpoints (Phase 5)
// Mock verifyIdToken BEFORE requiring the app
jest.mock('../src/config/firebase', () => ({
    initializeFirebaseAdmin: jest.fn(),
    verifyIdToken: jest.fn(),
}));

// Mock Mongoose models
jest.mock('../src/models/Facility');
jest.mock('../src/models/Doctor');

const request = require('supertest');
const { verifyIdToken } = require('../src/config/firebase');
const Facility = require('../src/models/Facility');
const Doctor = require('../src/models/Doctor');
const { createApp } = require('../src/app');

const app = createApp();

const VALID_TOKEN_PAYLOAD = {
    uid: 'firebase-uid-test-123',
    phone_number: '+919876543210',
};

const MOCK_FACILITIES = [
    {
        _id: '60d5ec49f1b2c8b1f8c8e001',
        name: 'PHC Koregaon',
        type: 'Primary Health Centre',
        address: 'Main Road, Koregaon, Satara',
        distance: '0.8 km',
        phone: '02163-123456',
        hours: 'Mon–Sat: 8am–4pm',
        isOpen: true,
        services: ['OPD', 'Maternity', 'Immunisation', 'Lab Tests'],
        isActive: true,
    },
    {
        _id: '60d5ec49f1b2c8b1f8c8e002',
        name: 'CHC Wai',
        type: 'Community Health Centre',
        address: 'Hospital Road, Wai, Satara',
        distance: '12 km',
        phone: '02167-234567',
        hours: 'Open 24 hours',
        isOpen: true,
        services: ['Emergency', 'Surgery', 'OPD', 'X-Ray', 'Lab', 'Pharmacy'],
        isActive: true,
    },
];

const MOCK_DOCTORS = [
    {
        _id: '60d5ec49f1b2c8b1f8c8d001',
        name: 'Dr. Rajesh Kumar',
        speciality: 'General Physician',
        qualification: 'MBBS, MD',
        facilityName: 'PHC Koregaon',
        experience: '12 years',
        availableSlots: 'Today, 10am–1pm',
        acceptsOnline: true,
        phone: '02163-123456',
        isActive: true,
    },
    {
        _id: '60d5ec49f1b2c8b1f8c8d002',
        name: 'Dr. Priya Sharma',
        speciality: 'Gynaecologist',
        qualification: 'MBBS, MS (OBG)',
        facilityName: 'CHC Wai',
        experience: '8 years',
        availableSlots: 'Tomorrow, 9am–12pm',
        acceptsOnline: false,
        phone: '02167-234567',
        isActive: true,
    },
];

describe('Phase 5 — Facilities & Doctors API', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        Facility.countDocuments.mockResolvedValue(2);
        Facility.find.mockReturnValue({
            sort: jest.fn().mockReturnValue({
                lean: jest.fn().mockResolvedValue(MOCK_FACILITIES),
            }),
        });
        Doctor.find.mockReturnValue({
            sort: jest.fn().mockReturnValue({
                lean: jest.fn().mockResolvedValue(MOCK_DOCTORS),
            }),
        });
    });

    describe('Authentication enforcement', () => {
        it('rejects GET /api/v1/facilities without auth header', async () => {
            const res = await request(app).get('/api/v1/facilities');
            expect(res.status).toBe(401);
            expect(res.body.error).toBe('UNAUTHORIZED');
        });

        it('rejects GET /api/v1/doctors without auth header', async () => {
            const res = await request(app).get('/api/v1/doctors');
            expect(res.status).toBe(401);
            expect(res.body.error).toBe('UNAUTHORIZED');
        });
    });

    describe('GET /api/v1/facilities', () => {
        it('returns all facilities when authenticated', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .get('/api/v1/facilities')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(Array.isArray(res.body.facilities)).toBe(true);
            expect(res.body.facilities.length).toBe(2);
            expect(res.body.facilities[0].name).toBe('PHC Koregaon');
            expect(res.body.facilities[0].type).toBe('Primary Health Centre');
        });
    });

    describe('GET /api/v1/facilities/:id', () => {
        it('returns a facility by ID', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            Facility.findOne.mockReturnValue({
                lean: jest.fn().mockResolvedValue(MOCK_FACILITIES[0]),
            });

            const res = await request(app)
                .get('/api/v1/facilities/60d5ec49f1b2c8b1f8c8e001')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(res.body.facility.name).toBe('PHC Koregaon');
        });

        it('returns 404 for unknown facility', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            Facility.findOne.mockReturnValue({
                lean: jest.fn().mockResolvedValue(null),
            });

            const res = await request(app)
                .get('/api/v1/facilities/unknown-id')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(404);
            expect(res.body.error).toBe('NOT_FOUND');
        });
    });

    describe('GET /api/v1/doctors', () => {
        it('returns all doctors when authenticated', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .get('/api/v1/doctors')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(Array.isArray(res.body.doctors)).toBe(true);
            expect(res.body.doctors.length).toBe(2);
            expect(res.body.doctors[0].name).toBe('Dr. Rajesh Kumar');
            expect(res.body.doctors[0].speciality).toBe('General Physician');
        });
    });

    describe('GET /api/v1/doctors/:id', () => {
        it('returns a doctor by ID', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            Doctor.findOne.mockReturnValue({
                lean: jest.fn().mockResolvedValue(MOCK_DOCTORS[0]),
            });

            const res = await request(app)
                .get('/api/v1/doctors/60d5ec49f1b2c8b1f8c8d001')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(res.body.doctor.name).toBe('Dr. Rajesh Kumar');
            expect(res.body.doctor.facility).toBe('PHC Koregaon');
        });

        it('returns 404 for unknown doctor', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            Doctor.findOne.mockReturnValue({
                lean: jest.fn().mockResolvedValue(null),
            });

            const res = await request(app)
                .get('/api/v1/doctors/unknown-id')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(404);
            expect(res.body.error).toBe('NOT_FOUND');
        });
    });
});
