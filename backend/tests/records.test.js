// Mock verifyIdToken BEFORE requiring the app
jest.mock('../src/config/firebase', () => ({
    initializeFirebaseAdmin: jest.fn(),
    verifyIdToken: jest.fn(),
}));

// Mock Mongoose models
jest.mock('../src/models/Patient');
jest.mock('../src/models/Prescription');
jest.mock('../src/models/Diagnostic');
jest.mock('../src/models/Referral');
jest.mock('../src/models/Consultation');

const request = require('supertest');
const { verifyIdToken } = require('../src/config/firebase');
const Patient = require('../src/models/Patient');
const Prescription = require('../src/models/Prescription');
const Diagnostic = require('../src/models/Diagnostic');
const Referral = require('../src/models/Referral');
const Consultation = require('../src/models/Consultation');
const { createApp } = require('../src/app');

const app = createApp();

const VALID_TOKEN_PAYLOAD = {
    uid: 'firebase-uid-123',
    phone_number: '+919876543210',
};

const PATIENT_DOC = {
    _id: '64b0f9c2e1234567890abcde',
    firebaseUid: 'firebase-uid-123',
    phone: '+919876543210',
    fullName: 'Sunita Devi',
    isActive: true,
};

const PRESCRIPTION_DOC = {
    _id: '64b0f9c2e1234567890abcf1',
    patientId: '64b0f9c2e1234567890abcde',
    doctorName: 'Dr. Priya Sharma',
    doctorSpecialty: 'General Physician',
    facilityName: 'Koregaon PHC',
    diagnosis: 'Iron Deficiency Anaemia',
    notes: 'Take with water',
    prescribedDate: new Date('2026-08-15'),
    validUntil: new Date('2026-10-15'),
    medications: [
        {
            name: 'Ferrous Sulfate',
            dosage: '100mg',
            frequency: 'Once daily',
            duration: '60 days',
            instructions: 'After lunch',
        },
    ],
};

const DIAGNOSTIC_DOC = {
    _id: '64b0f9c2e1234567890abcf2',
    patientId: '64b0f9c2e1234567890abcde',
    testName: 'Complete Blood Count (CBC)',
    testCategory: 'Haematology',
    facilityName: 'Satara Diagnostic Centre',
    orderedBy: 'Dr. Priya Sharma',
    status: 'COMPLETED',
    reportDate: new Date('2026-08-20'),
    resultSummary: 'Low Hb',
    results: [
        {
            parameter: 'Haemoglobin',
            value: '9.8',
            unit: 'g/dL',
            referenceRange: '12.0 - 15.5',
            isAbnormal: true,
        },
    ],
};

const REFERRAL_DOC = {
    _id: '64b0f9c2e1234567890abcf3',
    patientId: '64b0f9c2e1234567890abcde',
    fromFacility: 'Koregaon PHC',
    toFacility: 'Satara District Hospital',
    referringDoctor: 'Dr. Priya Sharma',
    specialtyRequired: 'Internal Medicine',
    reason: 'Chronic anaemia evaluation',
    priority: 'ROUTINE',
    status: 'APPOINTMENT_SCHEDULED',
    referralDate: new Date('2026-08-15'),
    appointmentDate: new Date('2026-09-05'),
    transportAssistance: false,
    notes: 'Bring previous reports',
};

const CONSULTATION_DOC = {
    _id: '64b0f9c2e1234567890abcf4',
    patientId: '64b0f9c2e1234567890abcde',
    doctorName: 'Dr. Priya Sharma',
    doctorSpecialty: 'General Physician',
    facilityName: 'Koregaon PHC',
    type: 'IN_PERSON',
    status: 'COMPLETED',
    consultationDate: new Date('2026-08-15'),
    symptoms: ['Fatigue'],
    diagnosis: 'Anaemia',
    doctorNotes: 'Advised repeat CBC in 4 weeks',
};

beforeEach(() => {
    jest.clearAllMocks();
    Patient.findOne.mockReturnValue({
        lean: jest.fn().mockResolvedValue(PATIENT_DOC),
    });
    Prescription.countDocuments.mockResolvedValue(1);
    Prescription.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
            lean: jest.fn().mockResolvedValue([PRESCRIPTION_DOC]),
        }),
        lean: jest.fn().mockResolvedValue([PRESCRIPTION_DOC]),
    });
    Diagnostic.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
            lean: jest.fn().mockResolvedValue([DIAGNOSTIC_DOC]),
        }),
        lean: jest.fn().mockResolvedValue([DIAGNOSTIC_DOC]),
    });
    Referral.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
            lean: jest.fn().mockResolvedValue([REFERRAL_DOC]),
        }),
        lean: jest.fn().mockResolvedValue([REFERRAL_DOC]),
    });
    Consultation.find.mockReturnValue({
        sort: jest.fn().mockReturnValue({
            lean: jest.fn().mockResolvedValue([CONSULTATION_DOC]),
        }),
        lean: jest.fn().mockResolvedValue([CONSULTATION_DOC]),
    });
});

describe('GET /api/v1/records/timeline', () => {
    test('rejects unauthenticated request (401)', async () => {
        const res = await request(app).get('/api/v1/records/timeline');
        expect(res.status).toBe(401);
    });

    test('returns unified chronological timeline for authenticated patient', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

        const res = await request(app)
            .get('/api/v1/records/timeline')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(Array.isArray(res.body.timeline)).toBe(true);
        expect(res.body.timeline.length).toBe(4);

        const types = res.body.timeline.map((item) => item.type);
        expect(types).toContain('Consultation');
        expect(types).toContain('Prescription');
        expect(types).toContain('Lab Report');
        expect(types).toContain('Referral');
    });
});

describe('GET /api/v1/records/prescriptions', () => {
    test('returns prescriptions list', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

        const res = await request(app)
            .get('/api/v1/records/prescriptions')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.prescriptions.length).toBe(1);
        expect(res.body.prescriptions[0].doctorName).toBe('Dr. Priya Sharma');
        expect(res.body.prescriptions[0].medications.length).toBe(1);
    });

    test('returns single prescription by id', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Prescription.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PRESCRIPTION_DOC),
        });

        const res = await request(app)
            .get('/api/v1/records/prescriptions/64b0f9c2e1234567890abcf1')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.prescription.doctorName).toBe('Dr. Priya Sharma');
        expect(res.body.prescription.diagnosis).toBe('Iron Deficiency Anaemia');
    });

    test('returns 404 for non-existent prescription', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Prescription.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(null),
        });

        const res = await request(app)
            .get('/api/v1/records/prescriptions/invalid-id')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(404);
    });
});

describe('GET /api/v1/records/lab-reports', () => {
    test('returns lab reports list and single report by id', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Diagnostic.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(DIAGNOSTIC_DOC),
        });

        const listRes = await request(app)
            .get('/api/v1/records/lab-reports')
            .set('Authorization', 'Bearer valid-token');

        expect(listRes.status).toBe(200);
        expect(listRes.body.labReports.length).toBe(1);
        expect(listRes.body.labReports[0].testName).toBe('Complete Blood Count (CBC)');

        const singleRes = await request(app)
            .get('/api/v1/records/lab-reports/64b0f9c2e1234567890abcf2')
            .set('Authorization', 'Bearer valid-token');

        expect(singleRes.status).toBe(200);
        expect(singleRes.body.labReport.results[0].parameter).toBe('Haemoglobin');
    });
});

describe('GET /api/v1/records/referrals', () => {
    test('returns referrals list and single referral by id', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Referral.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(REFERRAL_DOC),
        });

        const listRes = await request(app)
            .get('/api/v1/records/referrals')
            .set('Authorization', 'Bearer valid-token');

        expect(listRes.status).toBe(200);
        expect(listRes.body.referrals.length).toBe(1);
        expect(listRes.body.referrals[0].toFacility).toBe('Satara District Hospital');

        const singleRes = await request(app)
            .get('/api/v1/records/referrals/64b0f9c2e1234567890abcf3')
            .set('Authorization', 'Bearer valid-token');

        expect(singleRes.status).toBe(200);
        expect(singleRes.body.referral.priority).toBe('ROUTINE');
    });
});

describe('GET /api/v1/records/consultations', () => {
    test('returns consultations list and single consultation by id', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Consultation.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(CONSULTATION_DOC),
        });

        const listRes = await request(app)
            .get('/api/v1/records/consultations')
            .set('Authorization', 'Bearer valid-token');

        expect(listRes.status).toBe(200);
        expect(listRes.body.consultations.length).toBe(1);

        const singleRes = await request(app)
            .get('/api/v1/records/consultations/64b0f9c2e1234567890abcf4')
            .set('Authorization', 'Bearer valid-token');

        expect(singleRes.status).toBe(200);
        expect(singleRes.body.consultation.diagnosis).toBe('Anaemia');
    });
});
