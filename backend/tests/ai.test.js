// Unit tests for AI Health Assistant endpoints (Phase 7)
// Mock verifyIdToken BEFORE requiring the app
jest.mock('../src/config/firebase', () => ({
    initializeFirebaseAdmin: jest.fn(),
    verifyIdToken: jest.fn(),
}));

// Mock Mongoose models
jest.mock('../src/models/Patient');
jest.mock('../src/models/AiConversation');

const request = require('supertest');
const { verifyIdToken } = require('../src/config/firebase');
const Patient = require('../src/models/Patient');
const AiConversation = require('../src/models/AiConversation');
const { createApp } = require('../src/app');

const app = createApp();

const VALID_TOKEN_PAYLOAD = {
    uid: 'firebase-uid-ai-test-123',
    phone_number: '+919876543210',
};

const PATIENT_DOC = {
    _id: '64b0f9c2e1234567890abcde',
    firebaseUid: 'firebase-uid-ai-test-123',
    phone: '+919876543210',
    fullName: 'Sunita Devi',
    isActive: true,
};

const MOCK_MESSAGES = [
    {
        _id: '64b0f9c2e1234567890abcf1',
        patientId: '64b0f9c2e1234567890abcde',
        role: 'user',
        content: 'I have a mild fever',
        isEmergency: false,
        createdAt: new Date('2026-08-31T10:00:00Z'),
    },
    {
        _id: '64b0f9c2e1234567890abcf2',
        patientId: '64b0f9c2e1234567890abcde',
        role: 'assistant',
        content: 'Drink plenty of water and rest well.',
        isEmergency: false,
        createdAt: new Date('2026-08-31T10:00:02Z'),
    },
];

describe('Phase 7 — AI Health Assistant API', () => {
    beforeEach(() => {
        jest.clearAllMocks();
        process.env.GEMINI_API_KEY = 'test-gemini-key-123456';
        Patient.findOne.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
        Patient.findOneAndUpdate.mockReturnValue({
            lean: jest.fn().mockResolvedValue(PATIENT_DOC),
        });
        AiConversation.create.mockResolvedValue(true);
        AiConversation.deleteMany.mockResolvedValue({ deletedCount: 2 });
    });

    describe('Authentication enforcement', () => {
        it('rejects POST /api/v1/ai/chat without auth header', async () => {
            const res = await request(app)
                .post('/api/v1/ai/chat')
                .send({ message: 'Hello doctor' });
            expect(res.status).toBe(401);
            expect(res.body.error).toBe('UNAUTHORIZED');
        });

        it('rejects GET /api/v1/ai/history without auth header', async () => {
            const res = await request(app).get('/api/v1/ai/history');
            expect(res.status).toBe(401);
            expect(res.body.error).toBe('UNAUTHORIZED');
        });
    });

    describe('POST /api/v1/ai/chat', () => {
        it('rejects empty message with 400 BAD_REQUEST', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .post('/api/v1/ai/chat')
                .set('Authorization', 'Bearer valid-token')
                .send({ message: '' });

            expect(res.status).toBe(400);
            expect(res.body.error).toBe('BAD_REQUEST');
        });

        it('returns clinical triage guidance from Gemini response', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const mockGeminiReply = {
                candidates: [
                    {
                        content: {
                            parts: [
                                {
                                    text: '### What it could mean\nFever and cough can be caused by viral infections.\n\n### What you can do now\nRest and hydrate well.\n\nNote: This is general health information, not a formal medical diagnosis.',
                                },
                            ],
                        },
                    },
                ],
            };

            const originalFetch = global.fetch;
            global.fetch = jest.fn().mockResolvedValue({
                ok: true,
                json: jest.fn().mockResolvedValue(mockGeminiReply),
            });

            const res = await request(app)
                .post('/api/v1/ai/chat')
                .set('Authorization', 'Bearer valid-token')
                .send({ message: 'I have a fever and cough for 2 days' });

            expect(res.status).toBe(200);
            expect(typeof res.body.message).toBe('string');
            expect(res.body.message).toContain('What it could mean');
            expect(res.body.isEmergency).toBe(false);

            global.fetch = originalFetch;
        });

        it('detects emergency symptoms and flags isEmergency = true', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const mockGeminiReply = {
                candidates: [
                    {
                        content: {
                            parts: [
                                {
                                    text: 'This may be a medical emergency. Call 108 immediately.',
                                },
                            ],
                        },
                    },
                ],
            };

            const originalFetch = global.fetch;
            global.fetch = jest.fn().mockResolvedValue({
                ok: true,
                json: jest.fn().mockResolvedValue(mockGeminiReply),
            });

            const res = await request(app)
                .post('/api/v1/ai/chat')
                .set('Authorization', 'Bearer valid-token')
                .send({ message: 'My brother was bitten by a snake, severe pain' });

            expect(res.status).toBe(200);
            expect(res.body.isEmergency).toBe(true);
            expect(res.body.message).toContain('108');

            global.fetch = originalFetch;
        });
    });

    describe('GET /api/v1/ai/history', () => {
        it('returns formatted chat history for authenticated patient', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);
            AiConversation.find.mockReturnValue({
                sort: jest.fn().mockReturnValue({
                    limit: jest.fn().mockReturnValue({
                        lean: jest.fn().mockResolvedValue(MOCK_MESSAGES),
                    }),
                }),
            });

            const res = await request(app)
                .get('/api/v1/ai/history')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(Array.isArray(res.body.messages)).toBe(true);
            expect(res.body.messages.length).toBe(2);
            expect(res.body.messages[0].isAi).toBe(false);
            expect(res.body.messages[1].isAi).toBe(true);
        });
    });

    describe('DELETE /api/v1/ai/history', () => {
        it('clears conversation history for patient', async () => {
            verifyIdToken.mockResolvedValue(VALID_TOKEN_PAYLOAD);

            const res = await request(app)
                .delete('/api/v1/ai/history')
                .set('Authorization', 'Bearer valid-token');

            expect(res.status).toBe(200);
            expect(res.body.success).toBe(true);
        });
    });
});
