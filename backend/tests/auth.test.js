// Backend tests — Firebase token middleware + patient session flow
// Firebase Admin and Mongoose are mocked at module boundaries so tests are
// hermetic. Live Firebase/Atlas verification is a documented manual step.
jest.mock('../src/config/firebase', () => ({
    initializeFirebaseAdmin: jest.fn(),
    verifyIdToken: jest.fn(),
}));

jest.mock('../src/models/Patient', () => {
    const mockModel = jest.fn();
    mockModel.findOneAndUpdate = jest.fn().mockReturnValue({
        lean: jest.fn(),
    });
    mockModel.findOne = jest.fn().mockReturnValue({
        lean: jest.fn(),
    });
    return mockModel;
});

const request = require('supertest');
const { createApp } = require('../src/app');
const { verifyIdToken } = require('../src/config/firebase');
const Patient = require('../src/models/Patient');

const VALID_TOKEN_PAYLOAD = {
    uid: 'firebase-uid-123',
    phone_number: '+919876543210',
    aud: 'ruralcare-test',
    exp: Math.floor(Date.now() / 1000) + 3600,
};

const PATIENT_DOC = {
    _id: 'patient-object-id-1',
    firebaseUid: 'firebase-uid-123',
    phone: '+919876543210',
    role: 'PATIENT',
    isActive: true,
    fullName: 'Sunita Devi',
    age: 34,
    gender: 'Female',
    isPregnant: false,
    gestationalWeek: null,
    edd: '',
    emergencyContactName: '',
    emergencyContactPhone: '',
    abhaId: '',
    preferredLanguage: 'en',
    village: 'Koregaon',
    district: 'Satara',
    state: 'Maharashtra',
    bloodGroup: 'B+',
    allergies: ['Penicillin'],
    conditions: ['Anaemia', 'Hypertension'],
    createdAt: new Date('2026-08-28T00:00:00Z'),
    updatedAt: new Date('2026-08-28T00:00:00Z'),
};

let app;

beforeEach(() => {
    jest.clearAllMocks();
    app = createApp();
});

describe('Authentication middleware', () => {
    test('rejects request with no Authorization header (401)', async () => {
        const res = await request(app).post('/api/v1/auth/session');
        expect(res.status).toBe(401);
        expect(res.body.error).toBe('UNAUTHORIZED');
        expect(verifyIdToken).not.toHaveBeenCalled();
    });

    test('rejects malformed Authorization header (401)', async () => {
        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Token abc123');
        expect(res.status).toBe(401);
        expect(res.body.error).toBe('UNAUTHORIZED');
    });

    test('rejects invalid Firebase token (401)', async () => {
        verifyIdToken.mockRejectedValue(new Error('invalid signature'));

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer invalid-token');

        expect(res.status).toBe(401);
        expect(res.body.error).toBe('UNAUTHORIZED');
        // Must not leak internal error details
        expect(res.body.message).not.toContain('invalid signature');
    });

    test('rejects token without uid (401)', async () => {
        verifyIdToken.mockResolvedValue({ ...VALID_TOKEN_PAYLOAD, uid: undefined });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer some-token');

        expect(res.status).toBe(401);
    });

    test('accepts valid token and attaches verified identity', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(verifyIdToken).toHaveBeenCalledWith('valid-token');
        // Existing patient → not a new user, patient id returned.
        expect(res.body.isNewUser).toBe(false);
        expect(res.body.patient.id).toBe('patient-object-id-1');
        expect(res.body.patient.firebaseUid).toBe('firebase-uid-123');
    });
});

describe('POST /api/v1/auth/session — patient creation/retrieval', () => {
    test('returns existing patient for verified token', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.patient.firebaseUid).toBe('firebase-uid-123');
        expect(res.body.patient.phone).toBe('+919876543210');
        expect(res.body.patient.role).toBe('PATIENT');

        // Lookup must be keyed by the UID from the TOKEN, not from the body
        expect(Patient.findOneAndUpdate).toHaveBeenCalledWith(
            expect.objectContaining({ firebaseUid: 'firebase-uid-123' }),
            expect.anything(),
            expect.anything()
        );
    });

    test('ignores uid/patientId supplied in request body (security)', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token')
            .send({ uid: 'attacker-uid', patientId: 'someone-else' });

        // The query must use the token UID, never the body values
        expect(Patient.findOneAndUpdate).toHaveBeenCalledWith(
            expect.objectContaining({ firebaseUid: 'firebase-uid-123' }),
            expect.anything(),
            expect.anything()
        );
    });

    test('reports isNewUser=true for a brand-new patient record', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        // No existing record → the service treats this as a first-time user.
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(null),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.isNewUser).toBe(true);
    });

    test('returns 403 when patient is inactive', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue({ ...PATIENT_DOC, isActive: true }),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue({
                ...PATIENT_DOC,
                isActive: false,
            }),
        });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(403);
    });

    test('returns 500 (controlled) when database fails', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockRejectedValue(new Error('db down')),
        });

        const res = await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(500);
        expect(res.body.error).toBe('SERVER_ERROR');
    });
});

describe('GET /api/v1/patients/me — authenticated route protection', () => {
    test('rejects unauthenticated request (401)', async () => {
        const res = await request(app).get('/api/v1/patients/me');
        expect(res.status).toBe(401);
        expect(Patient.findOneAndUpdate).not.toHaveBeenCalled();
    });

    test('returns authenticated patient info', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .get('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.patient.firebaseUid).toBe('firebase-uid-123');
    });
});

describe('GET /api/v1/health', () => {
    test('returns ok without authentication', async () => {
        const res = await request(app).get('/api/v1/health');
        expect(res.status).toBe(200);
        expect(res.body.status).toBe('ok');
    });
});

describe('Duplicate prevention (service contract)', () => {
    test('findOrCreateByUid upserts on firebaseUid (same UID = same record)', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        // Two logins with the same token UID
        await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer token-1');
        await request(app)
            .post('/api/v1/auth/session')
            .set('Authorization', 'Bearer token-2');

        // Both queries keyed by the same firebaseUid — upsert guarantees one record
        const calls = Patient.findOneAndUpdate.mock.calls;
        expect(calls.length).toBe(2);
        expect(calls[0][0]).toEqual({ firebaseUid: 'firebase-uid-123' });
        expect(calls[1][0]).toEqual({ firebaseUid: 'firebase-uid-123' });
        // upsert: true in options
        expect(calls[0][2].upsert).toBe(true);
    });
});

describe('PUT /api/v1/patients/me — profile update (Phase 3)', () => {
    test('rejects unauthenticated request (401)', async () => {
        const res = await request(app).put('/api/v1/patients/me').send({ fullName: 'A' });
        expect(res.status).toBe(401);
        expect(Patient.findOneAndUpdate).not.toHaveBeenCalled();
    });

    test('updates editable profile fields and supports name alias', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue({
                ...PATIENT_DOC,
                fullName: 'Anita Pawar',
                age: 29,
                village: 'Wai',
                allergies: ['Sulfa drugs'],
            }),
        });

        const res = await request(app)
            .put('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token')
            .send({ name: 'Anita Pawar', age: 29, village: 'Wai', allergies: ['Sulfa drugs'] });

        expect(res.status).toBe(200);
        expect(res.body.patient.name).toBe('Anita Pawar');
        expect(res.body.patient.age).toBe(29);

        const { $set } = Patient.findOneAndUpdate.mock.calls[0][1];
        expect($set).toEqual({
            fullName: 'Anita Pawar',
            age: 29,
            village: 'Wai',
            allergies: ['Sulfa drugs'],
        });
    });

    test('updates pregnancy and contact fields successfully', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue({
                ...PATIENT_DOC,
                fullName: 'Rani Kumari',
                gender: 'Female',
                isPregnant: true,
                gestationalWeek: 20,
                emergencyContactName: 'Ramesh (Husband)',
                emergencyContactPhone: '9876543210',
            }),
        });

        const res = await request(app)
            .put('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token')
            .send({
                name: 'Rani Kumari',
                gender: 'Female',
                isPregnant: true,
                gestationalWeek: 20,
                emergencyContactName: 'Ramesh (Husband)',
                emergencyContactPhone: '9876543210',
            });

        expect(res.status).toBe(200);
        expect(res.body.patient.isPregnant).toBe(true);
        expect(res.body.patient.gestationalWeek).toBe(20);
        expect(res.body.patient.emergencyContactName).toBe('Ramesh (Husband)');

        const { $set } = Patient.findOneAndUpdate.mock.calls[0][1];
        expect($set.isPregnant).toBe(true);
        expect($set.gestationalWeek).toBe(20);
        expect($set.emergencyContactName).toBe('Ramesh (Husband)');
    });

    test('ignores identity/role fields sent in the body', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .put('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token')
            .send({
                id: 'hacked-id',
                firebaseUid: 'hacked-uid',
                phone: '+9999999999',
                role: 'DOCTOR',
                isActive: false,
                fullName: 'Sunita Devi',
            });

        expect(res.status).toBe(200);
        // Only the whitelisted fullName is set — identity fields are dropped.
        const { $set } = Patient.findOneAndUpdate.mock.calls[0][1];
        expect($set).toEqual({ fullName: 'Sunita Devi' });
    });

    test('returns 400 when no editable fields are provided', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

        const res = await request(app)
            .put('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token')
            .send({ role: 'DOCTOR', id: 'hacked' });

        expect(res.status).toBe(400);
        expect(Patient.findOneAndUpdate).not.toHaveBeenCalled();
    });

    test('returns 403 when patient is inactive', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue({ ...PATIENT_DOC, isActive: false }),
        });

        const res = await request(app)
            .put('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token')
            .send({ fullName: 'Anita' });

        expect(res.status).toBe(403);
    });
});

describe('GET /api/v1/patients/me — full profile (Phase 3)', () => {
    test('returns the patient profile fields required by the app', async () => {
        verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });

        const res = await request(app)
            .get('/api/v1/patients/me')
            .set('Authorization', 'Bearer valid-token');

        expect(res.status).toBe(200);
        expect(res.body.patient.firebaseUid).toBe('firebase-uid-123');
        expect(res.body.patient.name).toBe('Sunita Devi');
        expect(res.body.patient.age).toBe(34);
        expect(res.body.patient.gender).toBe('Female');
        expect(res.body.patient.village).toBe('Koregaon');
        expect(res.body.patient.district).toBe('Satara');
        expect(res.body.patient.state).toBe('Maharashtra');
        expect(res.body.patient.bloodGroup).toBe('B+');
        expect(res.body.patient.allergies).toEqual(['Penicillin']);
        expect(res.body.patient.conditions).toEqual(['Anaemia', 'Hypertension']);
    });
});