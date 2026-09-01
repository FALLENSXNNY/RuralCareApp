// Mock patient data — used until backend is ready
// Uses the real model classes from lib/core/models/
import '../models/ai_message.dart';
import '../models/consultation.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../models/lab_report.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/referral.dart';

/// Central mock data store
class MockPatientData {
  MockPatientData._();

  static const Patient currentPatient = Patient(
    id: 'P-001',
    name: 'Sunita Devi',
    phone: '+91 98765 43210',
    age: 34,
    gender: 'Female',
    village: 'Koregaon',
    district: 'Satara',
    state: 'Maharashtra',
    bloodGroup: 'B+',
    allergies: ['Penicillin'],
    conditions: ['Anaemia', 'Hypertension'],
  );

  static const List<Prescription> prescriptions = [
    Prescription(
      id: 'RX-001',
      doctorName: 'Dr. Rajesh Kumar',
      date: '22 Aug 2026',
      medicines: ['Ferrous Sulfate 200mg', 'Folic Acid 5mg', 'Vitamin C 500mg'],
      notes: 'Take with meals. Avoid tea/coffee within 1 hour.',
    ),
    Prescription(
      id: 'RX-002',
      doctorName: 'Dr. Priya Sharma',
      date: '10 Jul 2026',
      medicines: ['Amlodipine 5mg', 'Telmisartan 40mg'],
      notes: 'Take in the morning. Monitor BP daily.',
    ),
  ];

  static const List<LabReport> labReports = [
    LabReport(
      id: 'LAB-001',
      testName: 'Complete Blood Count (CBC)',
      date: '20 Aug 2026',
      result: 'Hb: 9.2 g/dL (Low)',
      status: 'Abnormal',
      facility: 'PHC Koregaon',
    ),
    LabReport(
      id: 'LAB-002',
      testName: 'Blood Pressure Check',
      date: '20 Aug 2026',
      result: '138/88 mmHg',
      status: 'Normal',
      facility: 'PHC Koregaon',
    ),
    LabReport(
      id: 'LAB-003',
      testName: 'Urine Routine',
      date: '10 Jul 2026',
      result: 'No abnormality detected',
      status: 'Normal',
      facility: 'PHC Koregaon',
    ),
  ];

  static const List<Referral> referrals = [
    Referral(
      id: 'REF-001',
      referredTo: 'District Hospital Satara',
      speciality: 'Gynaecology',
      date: '22 Aug 2026',
      reason: 'Severe anaemia — requires specialist review',
      status: 'Pending',
    ),
  ];

  static const List<Consultation> consultations = [
    Consultation(
      id: 'CON-001',
      doctorName: 'Dr. Rajesh Kumar',
      doctorSpeciality: 'General Physician',
      facility: 'PHC Koregaon',
      date: '20 Aug 2026',
      type: 'In-person',
      complaints: [
        'Fatigue and weakness for 2 weeks',
        'Dizziness when standing up',
        'Pale skin observed',
      ],
      diagnosis: 'Iron-Deficiency Anaemia',
      plan:
          '• Iron supplements prescribed for 3 months\n• CBC repeat after 6 weeks\n• Dietary advice: increase iron-rich foods\n• Referred to CHC Wai for specialist review',
    ),
  ];

  static const List<HealthcareFacility> facilities = [
    HealthcareFacility(
      id: 'FAC-001',
      name: 'PHC Koregaon',
      type: 'Primary Health Centre',
      address: 'Main Road, Koregaon, Satara',
      distance: '0.8 km',
      phone: '02163-123456',
      hours: 'Mon–Sat: 8am–4pm',
      isOpen: true,
      services: ['OPD', 'Maternity', 'Immunisation', 'Lab Tests'],
    ),
    HealthcareFacility(
      id: 'FAC-002',
      name: 'CHC Wai',
      type: 'Community Health Centre',
      address: 'Hospital Road, Wai, Satara',
      distance: '12 km',
      phone: '02167-234567',
      hours: 'Open 24 hours',
      isOpen: true,
      services: ['Emergency', 'Surgery', 'OPD', 'X-Ray', 'Lab', 'Pharmacy'],
    ),
    HealthcareFacility(
      id: 'FAC-003',
      name: 'District Hospital Satara',
      type: 'District Hospital',
      address: 'Civil Hospital Road, Satara',
      distance: '38 km',
      phone: '02162-234000',
      hours: 'Open 24 hours',
      isOpen: true,
      services: [
        'Emergency',
        'ICU',
        'Surgery',
        'Maternity',
        'Paediatrics',
        'Gynaecology',
        'Orthopaedics',
        'Eye',
        'ENT',
        'Lab',
        'X-Ray',
        'CT Scan',
      ],
    ),
  ];

  static const List<Doctor> doctors = [
    Doctor(
      id: 'DOC-001',
      name: 'Dr. Rajesh Kumar',
      speciality: 'General Physician',
      qualification: 'MBBS, MD',
      facility: 'PHC Koregaon',
      experience: '12 years',
      availableSlots: 'Today, 10am–1pm',
      acceptsOnline: true,
    ),
    Doctor(
      id: 'DOC-002',
      name: 'Dr. Priya Sharma',
      speciality: 'Gynaecologist',
      qualification: 'MBBS, MS (OBG)',
      facility: 'CHC Wai',
      experience: '8 years',
      availableSlots: 'Tomorrow, 9am–12pm',
      acceptsOnline: false,
    ),
    Doctor(
      id: 'DOC-003',
      name: 'Dr. Amit Patil',
      speciality: 'Paediatrician',
      qualification: 'MBBS, DCH',
      facility: 'District Hospital Satara',
      experience: '15 years',
      availableSlots: '30 Aug, 2pm–5pm',
      acceptsOnline: true,
    ),
  ];
}

/// Empty mock conversation list (clean start)
List<AiMessage> getMockAiConversation() {
  return [];
}
