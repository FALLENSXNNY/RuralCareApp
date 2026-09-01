// Controller for AI Health Assistant (Phase 7)
const aiService = require('../services/aiService');
const patientService = require('../services/patientService');

async function getPatientIdFromReq(req) {
    const patient = await patientService.findOrCreateByUid(req.uid, req.phoneNumber || '');
    return patient._id;
}

async function sendMessage(req, res, next) {
    try {
        const { message, history } = req.body;

        if (!message || typeof message !== 'string' || message.trim().length === 0) {
            return res.status(400).json({
                error: 'BAD_REQUEST',
                message: 'A non-empty message string is required.',
            });
        }

        const patientId = await getPatientIdFromReq(req);
        const result = await aiService.processChatMessage(patientId, message.trim(), history);

        res.status(200).json({
            message: result.message,
            isEmergency: result.isEmergency,
            timestamp: result.timestamp,
        });
    } catch (err) {
        next(err);
    }
}

async function getHistory(req, res, next) {
    try {
        const patientId = await getPatientIdFromReq(req);
        const limit = parseInt(req.query.limit, 10) || 50;
        const messages = await aiService.getChatHistory(patientId, limit);

        res.status(200).json({
            messages,
        });
    } catch (err) {
        next(err);
    }
}

async function clearHistory(req, res, next) {
    try {
        const patientId = await getPatientIdFromReq(req);
        await aiService.clearChatHistory(patientId);

        res.status(200).json({
            success: true,
            message: 'Chat history cleared successfully.',
        });
    } catch (err) {
        next(err);
    }
}

module.exports = {
    sendMessage,
    getHistory,
    clearHistory,
};
