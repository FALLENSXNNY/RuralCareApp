const MedicalDocument = require('../models/MedicalDocument');

const MAX_FILE_SIZE = 10 * 1024 * 1024; // 10MB limit

/**
 * Upload a medical document metadata and content.
 * POST /api/v1/documents
 */
async function uploadDocument(req, res, next) {
    try {
        const patientId = req.uid;
        if (!patientId) {
            return res.status(401).json({ error: 'Unauthorized: Patient ID missing.' });
        }

        const { title, documentType, fileUrl, fileData, mimeType, fileSize, notes } = req.body;

        if (!title || typeof title !== 'string' || title.trim().length === 0) {
            return res.status(400).json({ error: 'Document title is required.' });
        }

        if (fileSize && typeof fileSize === 'number' && fileSize > MAX_FILE_SIZE) {
            return res.status(400).json({ error: 'File size exceeds the 10MB limit.' });
        }

        const allowedTypes = [
            'Prescription',
            'Lab Report',
            'Discharge Summary',
            'X-Ray / Scan',
            'Insurance',
            'Medical Report',
            'Other',
        ];

        const sanitizedType = allowedTypes.includes(documentType) ? documentType : 'Other';

        const document = await MedicalDocument.create({
            patientId,
            title: title.trim(),
            documentType: sanitizedType,
            fileUrl: fileUrl || null,
            fileData: fileData || null,
            mimeType: mimeType || 'image/jpeg',
            fileSize: fileSize || (fileData ? Buffer.byteLength(fileData, 'utf8') : 0),
            notes: notes ? notes.trim() : '',
            uploadedAt: new Date(),
        });

        return res.status(201).json({
            message: 'Document uploaded successfully.',
            document: document.toJSON(),
        });
    } catch (err) {
        next(err);
    }
}

/**
 * Get all documents for the authenticated patient.
 * GET /api/v1/documents
 */
async function getDocuments(req, res, next) {
    try {
        const patientId = req.uid;
        if (!patientId) {
            return res.status(401).json({ error: 'Unauthorized: Patient ID missing.' });
        }

        const { type } = req.query;
        const query = { patientId };
        if (type && type !== 'All') {
            query.documentType = type;
        }

        const docs = await MedicalDocument.find(query)
            .sort({ uploadedAt: -1 })
            .limit(100);

        return res.status(200).json({
            count: docs.length,
            documents: docs.map((d) => d.toJSON()),
        });
    } catch (err) {
        next(err);
    }
}

/**
 * Get single document by ID.
 * GET /api/v1/documents/:id
 */
async function getDocumentById(req, res, next) {
    try {
        const patientId = req.uid;
        const { id } = req.params;

        const doc = await MedicalDocument.findOne({ _id: id, patientId });
        if (!doc) {
            return res.status(404).json({ error: 'Medical document not found.' });
        }

        return res.status(200).json({
            document: doc.toJSON(),
        });
    } catch (err) {
        next(err);
    }
}

/**
 * Delete a document by ID.
 * DELETE /api/v1/documents/:id
 */
async function deleteDocument(req, res, next) {
    try {
        const patientId = req.uid;
        const { id } = req.params;

        const deleted = await MedicalDocument.findOneAndDelete({ _id: id, patientId });
        if (!deleted) {
            return res.status(404).json({ error: 'Medical document not found.' });
        }

        return res.status(200).json({
            message: 'Document deleted successfully.',
            id,
        });
    } catch (err) {
        next(err);
    }
}

module.exports = {
    uploadDocument,
    getDocuments,
    getDocumentById,
    deleteDocument,
};
