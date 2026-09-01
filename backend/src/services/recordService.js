// Record service — manages clinical records (prescriptions, diagnostics,
// referrals, consultations) and the unified longitudinal health timeline.
// SECURITY: All queries are strictly scoped by the patient's verified firebaseUid.
const Patient = require('../models/Patient');
const Prescription = require('../models/Prescription');
const Diagnostic = require('../models/Diagnostic');
const Referral = require('../models/Referral');
const Consultation = require('../models/Consultation');

/**
 * Finds the patient doc for a verified UID, throwing 404/403 if invalid.
 */
async function getPatientOrThrow(firebaseUid) {
    const patient = await Patient.findOne({ firebaseUid }).lean();
    if (!patient) {
        const err = new Error('Patient profile not found.');
        err.status = 404;
        throw err;
    }
    if (patient.isActive === false) {
        const err = new Error('This account is inactive.');
        err.status = 403;
        throw err;
    }
    return patient;
}

/**
 * Seeds initial demo clinical records for a new patient if they currently have none.
 */
async function seedStarterRecordsIfEmpty(patientId) {
    const count = await Prescription.countDocuments({ patientId });
    if (count > 0) return;

    const now = new Date();
    const twoDaysAgo = new Date(now.getTime() - 2 * 24 * 60 * 60 * 1000);
    const twoWeeksAgo = new Date(now.getTime() - 14 * 24 * 60 * 60 * 1000);
    const oneMonthAgo = new Date(now.getTime() - 30 * 24 * 60 * 60 * 1000);

    // 1. Initial Consultation
    const consultation = await Consultation.create({
        patientId,
        doctorName: 'Dr. Priya Sharma',
        doctorSpecialty: 'General Physician',
        facilityName: 'Koregaon Primary Health Centre',
        type: 'IN_PERSON',
        status: 'COMPLETED',
        consultationDate: twoWeeksAgo,
        symptoms: ['Fatigue', 'Dizziness', 'Mild headache'],
        diagnosis: 'Mild Iron Deficiency Anaemia',
        doctorNotes: 'Patient presented with 2-week history of fatigue. Started on iron supplementation and dietary advice. Advised repeat CBC in 4 weeks.',
    });

    // 2. Prescription
    await Prescription.create({
        patientId,
        doctorName: 'Dr. Priya Sharma',
        doctorSpecialty: 'General Physician',
        facilityName: 'Koregaon Primary Health Centre',
        diagnosis: 'Iron Deficiency Anaemia',
        notes: 'Take tablets after meals. Increase green leafy vegetables and jaggery in diet.',
        prescribedDate: twoWeeksAgo,
        validUntil: new Date(now.getTime() + 60 * 24 * 60 * 60 * 1000),
        medications: [
            {
                name: 'Ferrous Sulfate + Folic Acid',
                dosage: '100mg / 0.5mg',
                frequency: 'Once daily',
                duration: '60 days',
                instructions: 'Take after lunch with water',
            },
            {
                name: 'Vitamin C (Ascorbic Acid)',
                dosage: '500mg',
                frequency: 'Once daily',
                duration: '30 days',
                instructions: 'Improves iron absorption',
            },
        ],
    });

    // 3. Lab Report (CBC)
    await Diagnostic.create({
        patientId,
        testName: 'Complete Blood Count (CBC)',
        testCategory: 'Haematology',
        facilityName: 'Satara District Diagnostic Centre',
        orderedBy: 'Dr. Priya Sharma',
        status: 'COMPLETED',
        reportDate: twoDaysAgo,
        resultSummary: 'Haemoglobin is low (9.8 g/dL). Microcytic hypochromic picture noted.',
        results: [
            {
                parameter: 'Haemoglobin (Hb)',
                value: '9.8',
                unit: 'g/dL',
                referenceRange: '12.0 - 15.5',
                isAbnormal: true,
            },
            {
                parameter: 'RBC Count',
                value: '3.9',
                unit: 'million/mcL',
                referenceRange: '4.0 - 5.2',
                isAbnormal: true,
            },
            {
                parameter: 'WBC Count',
                value: '6800',
                unit: 'cells/mcL',
                referenceRange: '4500 - 11000',
                isAbnormal: false,
            },
            {
                parameter: 'Platelets',
                value: '240000',
                unit: 'cells/mcL',
                referenceRange: '150000 - 450000',
                isAbnormal: false,
            },
        ],
    });

    // 4. Referral
    await Referral.create({
        patientId,
        fromFacility: 'Koregaon Primary Health Centre',
        toFacility: 'Satara District Civil Hospital',
        referringDoctor: 'Dr. Priya Sharma',
        specialtyRequired: 'Internal Medicine / Nutrition Clinic',
        reason: 'Evaluation for chronic anaemia management and dietary therapy',
        priority: 'ROUTINE',
        status: 'APPOINTMENT_SCHEDULED',
        referralDate: twoWeeksAgo,
        appointmentDate: new Date(now.getTime() + 5 * 24 * 60 * 60 * 1000),
        transportAssistance: false,
        notes: 'Please bring latest CBC report and current medication strip.',
    });
}

function formatDate(date) {
    if (!date) return '';
    return new Date(date).toLocaleDateString('en-GB', {
        day: '2-digit',
        month: 'short',
        year: 'numeric',
    });
}

// ── Timeline ─────────────────────────────────────────────────────────────────

async function getHealthTimeline(firebaseUid) {
    const patient = await getPatientOrThrow(firebaseUid);
    await seedStarterRecordsIfEmpty(patient._id);

    const [consultations, prescriptions, diagnostics, referrals] = await Promise.all([
        Consultation.find({ patientId: patient._id }).lean(),
        Prescription.find({ patientId: patient._id }).lean(),
        Diagnostic.find({ patientId: patient._id }).lean(),
        Referral.find({ patientId: patient._id }).lean(),
    ]);

    const timeline = [];

    for (const c of consultations) {
        timeline.push({
            id: c._id.toString(),
            type: 'Consultation',
            title: `${c.doctorName} • ${c.facilityName}`,
            subtitle: c.diagnosis || c.symptoms.join(', ') || 'General Consultation',
            date: formatDate(c.consultationDate),
            rawDate: c.consultationDate,
            relatedId: c._id.toString(),
        });
    }

    for (const p of prescriptions) {
        timeline.push({
            id: p._id.toString(),
            type: 'Prescription',
            title: `Prescription by ${p.doctorName}`,
            subtitle: `${p.medications.length} medication${p.medications.length === 1 ? '' : 's'}: ${p.medications.map((m) => m.name).join(', ')}`,
            date: formatDate(p.prescribedDate),
            rawDate: p.prescribedDate,
            relatedId: p._id.toString(),
        });
    }

    for (const d of diagnostics) {
        timeline.push({
            id: d._id.toString(),
            type: 'Lab Report',
            title: d.testName,
            subtitle: `${d.facilityName} • ${d.resultSummary || d.status}`,
            date: formatDate(d.reportDate),
            rawDate: d.reportDate,
            relatedId: d._id.toString(),
        });
    }

    for (const r of referrals) {
        timeline.push({
            id: r._id.toString(),
            type: 'Referral',
            title: `Referral to ${r.toFacility}`,
            subtitle: `${r.specialtyRequired} (${r.status})`,
            date: formatDate(r.referralDate),
            rawDate: r.referralDate,
            relatedId: r._id.toString(),
        });
    }

    timeline.sort((a, b) => new Date(b.rawDate) - new Date(a.rawDate));
    return timeline.map(({ rawDate, ...item }) => item);
}

// ── Prescriptions ────────────────────────────────────────────────────────────

async function getPrescriptions(firebaseUid) {
    const patient = await getPatientOrThrow(firebaseUid);
    await seedStarterRecordsIfEmpty(patient._id);
    const docs = await Prescription.find({ patientId: patient._id }).sort({ prescribedDate: -1 }).lean();

    return docs.map((p) => ({
        id: p._id.toString(),
        doctorName: p.doctorName,
        doctorSpecialty: p.doctorSpecialty,
        facilityName: p.facilityName,
        date: formatDate(p.prescribedDate),
        diagnosis: p.diagnosis,
        notes: p.notes,
        validUntil: formatDate(p.validUntil),
        medications: p.medications.map((m) => ({
            name: m.name,
            dosage: m.dosage,
            frequency: m.frequency,
            duration: m.duration,
            instructions: m.instructions,
        })),
    }));
}

async function getPrescriptionById(firebaseUid, id) {
    const patient = await getPatientOrThrow(firebaseUid);
    const p = await Prescription.findOne({ _id: id, patientId: patient._id }).lean();
    if (!p) {
        const err = new Error('Prescription not found.');
        err.status = 404;
        throw err;
    }
    return {
        id: p._id.toString(),
        doctorName: p.doctorName,
        doctorSpecialty: p.doctorSpecialty,
        facilityName: p.facilityName,
        date: formatDate(p.prescribedDate),
        diagnosis: p.diagnosis,
        notes: p.notes,
        validUntil: formatDate(p.validUntil),
        medications: p.medications.map((m) => ({
            name: m.name,
            dosage: m.dosage,
            frequency: m.frequency,
            duration: m.duration,
            instructions: m.instructions,
        })),
    };
}

// ── Lab Reports / Diagnostics ────────────────────────────────────────────────

async function getLabReports(firebaseUid) {
    const patient = await getPatientOrThrow(firebaseUid);
    await seedStarterRecordsIfEmpty(patient._id);
    const docs = await Diagnostic.find({ patientId: patient._id }).sort({ reportDate: -1 }).lean();

    return docs.map((d) => ({
        id: d._id.toString(),
        testName: d.testName,
        facilityName: d.facilityName,
        date: formatDate(d.reportDate),
        orderedBy: d.orderedBy,
        status: d.status,
        resultSummary: d.resultSummary,
        results: d.results.map((r) => ({
            parameter: r.parameter,
            value: r.value,
            unit: r.unit,
            referenceRange: r.referenceRange,
            isAbnormal: r.isAbnormal,
        })),
    }));
}

async function getLabReportById(firebaseUid, id) {
    const patient = await getPatientOrThrow(firebaseUid);
    const d = await Diagnostic.findOne({ _id: id, patientId: patient._id }).lean();
    if (!d) {
        const err = new Error('Lab report not found.');
        err.status = 404;
        throw err;
    }
    return {
        id: d._id.toString(),
        testName: d.testName,
        facilityName: d.facilityName,
        date: formatDate(d.reportDate),
        orderedBy: d.orderedBy,
        status: d.status,
        resultSummary: d.resultSummary,
        results: d.results.map((r) => ({
            parameter: r.parameter,
            value: r.value,
            unit: r.unit,
            referenceRange: r.referenceRange,
            isAbnormal: r.isAbnormal,
        })),
    };
}

// ── Referrals ────────────────────────────────────────────────────────────────

async function getReferrals(firebaseUid) {
    const patient = await getPatientOrThrow(firebaseUid);
    await seedStarterRecordsIfEmpty(patient._id);
    const docs = await Referral.find({ patientId: patient._id }).sort({ referralDate: -1 }).lean();

    return docs.map((r) => ({
        id: r._id.toString(),
        fromFacility: r.fromFacility,
        toFacility: r.toFacility,
        referringDoctor: r.referringDoctor,
        specialtyRequired: r.specialtyRequired,
        reason: r.reason,
        priority: r.priority,
        status: r.status,
        referralDate: formatDate(r.referralDate),
        appointmentDate: formatDate(r.appointmentDate),
        transportAssistance: r.transportAssistance,
        notes: r.notes,
    }));
}

async function getReferralById(firebaseUid, id) {
    const patient = await getPatientOrThrow(firebaseUid);
    const r = await Referral.findOne({ _id: id, patientId: patient._id }).lean();
    if (!r) {
        const err = new Error('Referral not found.');
        err.status = 404;
        throw err;
    }
    return {
        id: r._id.toString(),
        fromFacility: r.fromFacility,
        toFacility: r.toFacility,
        referringDoctor: r.referringDoctor,
        specialtyRequired: r.specialtyRequired,
        reason: r.reason,
        priority: r.priority,
        status: r.status,
        referralDate: formatDate(r.referralDate),
        appointmentDate: formatDate(r.appointmentDate),
        transportAssistance: r.transportAssistance,
        notes: r.notes,
    };
}

// ── Consultations ────────────────────────────────────────────────────────────

async function getConsultations(firebaseUid) {
    const patient = await getPatientOrThrow(firebaseUid);
    await seedStarterRecordsIfEmpty(patient._id);
    const docs = await Consultation.find({ patientId: patient._id }).sort({ consultationDate: -1 }).lean();

    return docs.map((c) => ({
        id: c._id.toString(),
        doctorName: c.doctorName,
        doctorSpecialty: c.doctorSpecialty,
        facilityName: c.facilityName,
        date: formatDate(c.consultationDate),
        symptoms: c.symptoms,
        diagnosis: c.diagnosis,
        doctorNotes: c.doctorNotes,
        followUpDate: formatDate(c.followUpDate),
    }));
}

async function getConsultationById(firebaseUid, id) {
    const patient = await getPatientOrThrow(firebaseUid);
    const c = await Consultation.findOne({ _id: id, patientId: patient._id }).lean();
    if (!c) {
        const err = new Error('Consultation not found.');
        err.status = 404;
        throw err;
    }
    return {
        id: c._id.toString(),
        doctorName: c.doctorName,
        doctorSpecialty: c.doctorSpecialty,
        facilityName: c.facilityName,
        date: formatDate(c.consultationDate),
        symptoms: c.symptoms,
        diagnosis: c.diagnosis,
        doctorNotes: c.doctorNotes,
        followUpDate: formatDate(c.followUpDate),
    };
}

module.exports = {
    getHealthTimeline,
    getPrescriptions,
    getPrescriptionById,
    getLabReports,
    getLabReportById,
    getReferrals,
    getReferralById,
    getConsultations,
    getConsultationById,
};
