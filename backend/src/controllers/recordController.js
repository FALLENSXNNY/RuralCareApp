// Record controller — handles REST requests for patient health records.
// SECURITY: The authenticated Firebase UID (req.uid) is passed to the service
// to ensure complete data isolation.
const recordService = require('../services/recordService');

async function getTimeline(req, res, next) {
    try {
        const timeline = await recordService.getHealthTimeline(req.uid);
        return res.status(200).json({ timeline });
    } catch (err) {
        return next(err);
    }
}

async function getPrescriptions(req, res, next) {
    try {
        const prescriptions = await recordService.getPrescriptions(req.uid);
        return res.status(200).json({ prescriptions });
    } catch (err) {
        return next(err);
    }
}

async function getPrescription(req, res, next) {
    try {
        const prescription = await recordService.getPrescriptionById(req.uid, req.params.id);
        return res.status(200).json({ prescription });
    } catch (err) {
        return next(err);
    }
}

async function getLabReports(req, res, next) {
    try {
        const labReports = await recordService.getLabReports(req.uid);
        return res.status(200).json({ labReports });
    } catch (err) {
        return next(err);
    }
}

async function getLabReport(req, res, next) {
    try {
        const labReport = await recordService.getLabReportById(req.uid, req.params.id);
        return res.status(200).json({ labReport });
    } catch (err) {
        return next(err);
    }
}

async function getReferrals(req, res, next) {
    try {
        const referrals = await recordService.getReferrals(req.uid);
        return res.status(200).json({ referrals });
    } catch (err) {
        return next(err);
    }
}

async function getReferral(req, res, next) {
    try {
        const referral = await recordService.getReferralById(req.uid, req.params.id);
        return res.status(200).json({ referral });
    } catch (err) {
        return next(err);
    }
}

async function getConsultations(req, res, next) {
    try {
        const consultations = await recordService.getConsultations(req.uid);
        return res.status(200).json({ consultations });
    } catch (err) {
        return next(err);
    }
}

async function getConsultation(req, res, next) {
    try {
        const consultation = await recordService.getConsultationById(req.uid, req.params.id);
        return res.status(200).json({ consultation });
    } catch (err) {
        return next(err);
    }
}

module.exports = {
    getTimeline,
    getPrescriptions,
    getPrescription,
    getLabReports,
    getLabReport,
    getReferrals,
    getReferral,
    getConsultations,
    getConsultation,
};
