// Unit tests for Medical Document endpoints (Phase 8)
jest.mock('../src/config/firebase', () => ({
    initializeFirebaseAdmin: jest.fn(),
    verifyIdToken: jest.fn(),
}));

jest.mock('../src/models/Patient');
jest.mock('../src/models/MedicalDocument');

const request = require('supertest');
const { verifyIdToken } = require('../src/config/firebase');
const Patient = require('../src/models/Patient');
const MedicalDocument = require('../src/models/MedicalDocument');
const { createApp } = require('../src/app');

const app = createApp();

const VALID_TOKEN_PAYLOAD = {
    uid: 'firebase-uid-doc-test-123',
    phone_number: '+919876543210',
};

const PATIENT_DOC = {
    _id: '64b0f9c2e1234567890abcde',
    firebaseUid: 'firebase-uid-doc-test-123',
    phone: '+919876543210',
    fullName: 'Sunita Devi',
    isActive: true,
};

const MOCK_DOCUMENT = {
    _id: '64b0f9c2e1234567890abcd1',
    patientId: '64b0f9c2e1234567890abcde',
    title: 'CBC Blood Test Report',
    documentType: 'Lab Report',
    fileUrl: 'https://storage.ruralcare.in/docs/cbc_test.pdf',
    fileData: 'base64sampledata',
    mimeType: 'application/pdf',
    fileSize: 1048576,
    notes: 'Hemoglobin slightly low',
    uploadedAt: new Date('2026-08-31T12:00:00Z'),
    toJSON() {
        return {
            id: '64b0f9c2e1234567890abcd1',
            patientId: this.patientId,
            title: this.title,
            documentType: this.documentType,
            fileUrl: this.fileUrl,
            fileData: this.fileData,
            mimeType: this.mimeType,
            fileSize: this.fileSize,
            notes: this.notes,
            uploadedAt: this.uploadedAt.toISOString(),
        };
    },
};

describe('Phase 8 — Medical Documents API', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
    });

    describe('POST /api/v1/documents', () => {
        it('returns 401 when Authorization header is missing', async () => {
            const res = await request(app)
                .post('/api/v1/documents')
                .send({ title: 'Prescription 2026' });

            expect(res.status).toBe(401);
            expect(res.body.error).toMatch(/unauthorized/i);
        });

        it('returns 400 when title is missing', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .post('/api/v1/documents')
                .set('Authorization', 'Bearer valid-test-token')
                .send({ documentType: 'Prescription' });

            expect(res.status).toBe(400);
            expect(res.body.error).toMatch(/title is required/i);
        });

        it('returns 400 when file size exceeds 10MB', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .post('/api/v1/documents')
                .set('Authorization', 'Bearer valid-test-token')
                .send({
                    title: 'Large Scan',
                    fileSize: 15 * 1024 * 1024,
                });

            expect(res.status).toBe(400);
            expect(res.body.error).toMatch(/10MB/i);
        });

        it('successfully uploads and creates medical document record', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.create.mockResolvedValue(MOCK_DOCUMENT);

            const res = await request(app)
                .post('/api/v1/documents')
                .set('Authorization', 'Bearer valid-test-token')
                .send({
                    title: 'CBC Blood Test Report',
                    documentType: 'Lab Report',
                    fileData: 'base64sampledata',
                    mimeType: 'application/pdf',
                    notes: 'Hemoglobin slightly low',
                });

            expect(res.status).toBe(201);
            expect(res.body.message).toMatch(/uploaded successfully/i);
            expect(res.body.document).toBeDefined();
            expect(res.body.document.title).toBe('CBC Blood Test Report');
            expect(res.body.document.documentType).toBe('Lab Report');
        });
    });

    describe('GET /api/v1/documents', () => {
        it('retrieves patient documents list', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.find.mockReturnValue({
                sort: jest.fn().mockReturnValue({
                    limit: jest.fn().mockResolvedValue([MOCK_DOCUMENT]),
                }),
            });

            const res = await request(app)
                .get('/api/v1/documents')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(200);
            expect(res.body.count).toBe(1);
            expect(res.body.documents[0].title).toBe('CBC Blood Test Report');
        });

        it('supports filtering by documentType', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.find.mockReturnValue({
                sort: jest.fn().mockReturnValue({
                    limit: jest.fn().mockResolvedValue([MOCK_DOCUMENT]),
                }),
            });

            const res = await request(app)
                .get('/api/v1/documents?type=Lab+Report')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(200);
            expect(MedicalDocument.find).toHaveBeenCalledWith(
                expect.objectContaining({
                    documentType: 'Lab Report',
                })
            );
        });
    });

    describe('GET /api/v1/documents/:id', () => {
        it('returns 404 when document does not exist or not owned', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.findOne.mockResolvedValue(null);

            const res = await request(app)
                .get('/api/v1/documents/non-existent-id')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(404);
            expect(res.body.error).toMatch(/not found/i);
        });

        it('returns document detail when owned by patient', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.findOne.mockResolvedValue(MOCK_DOCUMENT);

            const res = await request(app)
                .get('/api/v1/documents/64b0f9c2e1234567890abcd1')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(200);
            expect(res.body.document.id).toBe('64b0f9c2e1234567890abcd1');
        });
    });

    describe('DELETE /api/v1/documents/:id', () => {
        it('successfully deletes patient document', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.findOneAndDelete.mockResolvedValue(MOCK_DOCUMENT);

            const res = await request(app)
                .delete('/api/v1/documents/64b0f9c2e1234567890abcd1')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(200);
            expect(res.body.message).toMatch(/deleted successfully/i);
            expect(res.body.id).toBe('64b0f9c2e1234567890abcd1');
        });

        it('returns 404 when document to delete is not found', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            MedicalDocument.findOneAndDelete.mockResolvedValue(null);

            const res = await request(app)
                .delete('/api/v1/documents/non-existent-id')
                .set('Authorization', 'Bearer valid-test-token');

            expect(res.status).toBe(404);
        });
    });
});
