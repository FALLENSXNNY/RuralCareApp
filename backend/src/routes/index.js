const express = require('express');
const { authenticate } = require('../middleware/authenticate');
const authController = require('../controllers/authController');
const patientController = require('../controllers/patientController');
const recordController = require('../controllers/recordController');
const facilityController = require('../controllers/facilityController');
const aiController = require('../controllers/aiController');
const documentController = require('../controllers/documentController');
const healthcareController = require('../controllers/healthcareController');

const router = express.Router();

// Health check — unauthenticated, no sensitive info
router.get('/health', (req, res) => {
    res.status(200).json({ status: 'ok', service: 'ruralcare-backend' });
});

// Auth — exchanges a verified Firebase ID token for a patient session
router.post('/auth/session', authenticate, authController.createSession);

// Patient — authenticated, identity derived from token
router.get('/patients/me', authenticate, patientController.getMe);
router.put('/patients/me', authenticate, patientController.updateMe);

// Records — authenticated clinical health records and timeline
router.get('/records/timeline', authenticate, recordController.getTimeline);
router.get('/records/prescriptions', authenticate, recordController.getPrescriptions);
router.get('/records/prescriptions/:id', authenticate, recordController.getPrescription);
router.get('/records/lab-reports', authenticate, recordController.getLabReports);
router.get('/records/lab-reports/:id', authenticate, recordController.getLabReport);
router.get('/records/referrals', authenticate, recordController.getReferrals);
router.get('/records/referrals/:id', authenticate, recordController.getReferral);
router.get('/records/consultations', authenticate, recordController.getConsultations);
router.get('/records/consultations/:id', authenticate, recordController.getConsultation);

// Facilities & Doctors — authenticated healthcare provider access
router.get('/facilities', authenticate, facilityController.getFacilities);
router.get('/facilities/:id', authenticate, facilityController.getFacilityById);
router.get('/doctors', authenticate, facilityController.getDoctors);
router.get('/doctors/:id', authenticate, facilityController.getDoctorById);

// Medical Documents — authenticated upload, retrieval, and deletion
router.post('/documents', authenticate, documentController.uploadDocument);
router.get('/documents', authenticate, documentController.getDocuments);
router.get('/documents/:id', authenticate, documentController.getDocumentById);
router.delete('/documents/:id', authenticate, documentController.deleteDocument);

// AI Health Assistant — authenticated conversational guidance
router.post('/ai/chat', authenticate, aiController.sendMessage);
router.get('/ai/history', authenticate, aiController.getHistory);
router.delete('/ai/history', authenticate, aiController.clearHistory);

// GPS Healthcare Finder — Places & Directions
router.get('/healthcare/nearby', healthcareController.getNearby);
router.get('/healthcare/details/:placeId', healthcareController.getDetails);
router.get('/healthcare/directions', healthcareController.getDirections);

module.exports = router;