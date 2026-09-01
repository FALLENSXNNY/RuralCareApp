// Unit tests for data model serialization
import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/ai_message.dart';
import 'package:ruralcare/core/models/consultation.dart';
import 'package:ruralcare/core/models/doctor.dart';
import 'package:ruralcare/core/models/facility.dart';
import 'package:ruralcare/core/models/health_record.dart';
import 'package:ruralcare/core/models/lab_report.dart';
import 'package:ruralcare/core/models/medical_document.dart';
import 'package:ruralcare/core/models/patient.dart';
import 'package:ruralcare/core/models/prescription.dart';
import 'package:ruralcare/core/models/referral.dart';

void main() {
  group('Patient model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'P-001',
        'name': 'Sunita Devi',
        'phone': '+91 98765 43210',
        'age': 34,
        'gender': 'Female',
        'village': 'Koregaon',
        'district': 'Satara',
        'state': 'Maharashtra',
        'bloodGroup': 'B+',
        'allergies': ['Penicillin'],
        'conditions': ['Anaemia', 'Hypertension'],
      };

      final patient = Patient.fromJson(json);
      expect(patient.id, 'P-001');
      expect(patient.name, 'Sunita Devi');
      expect(patient.age, 34);
      expect(patient.allergies, ['Penicillin']);
      expect(patient.conditions, ['Anaemia', 'Hypertension']);

      final roundtrip = Patient.fromJson(patient.toJson());
      expect(roundtrip.id, patient.id);
      expect(roundtrip.name, patient.name);
      expect(roundtrip.age, patient.age);
      expect(roundtrip.allergies, patient.allergies);
    });

    test('fromJson handles missing fields', () {
      final patient = Patient.fromJson({});
      expect(patient.id, '');
      expect(patient.name, '');
      expect(patient.age, 0);
      expect(patient.allergies, isEmpty);
      expect(patient.conditions, isEmpty);
    });

    test('copyWith updates fields', () {
      const patient = Patient(
        id: 'P-001',
        name: 'Sunita',
        phone: '123',
        age: 30,
        gender: 'Female',
        village: 'V',
        district: 'D',
        state: 'S',
        bloodGroup: 'B+',
        allergies: [],
        conditions: [],
      );
      final updated = patient.copyWith(name: 'Sunita Devi', age: 34);
      expect(updated.name, 'Sunita Devi');
      expect(updated.age, 34);
      expect(updated.id, 'P-001');
    });
  });

  group('Prescription model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'RX-001',
        'doctorName': 'Dr. Rajesh Kumar',
        'date': '22 Aug 2026',
        'medicines': ['Ferrous Sulfate 200mg', 'Folic Acid 5mg'],
        'notes': 'Take with meals.',
      };

      final rx = Prescription.fromJson(json);
      expect(rx.id, 'RX-001');
      expect(rx.doctorName, 'Dr. Rajesh Kumar');
      expect(rx.medicines.length, 2);

      final roundtrip = Prescription.fromJson(rx.toJson());
      expect(roundtrip.id, rx.id);
      expect(roundtrip.medicines, rx.medicines);
    });
  });

  group('LabReport model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'LAB-001',
        'testName': 'CBC',
        'date': '20 Aug 2026',
        'result': 'Hb: 9.2 g/dL',
        'status': 'Abnormal',
        'facility': 'PHC Koregaon',
      };

      final report = LabReport.fromJson(json);
      expect(report.id, 'LAB-001');
      expect(report.isAbnormal, true);

      final roundtrip = LabReport.fromJson(report.toJson());
      expect(roundtrip.status, 'Abnormal');
      expect(roundtrip.isAbnormal, true);
    });
  });

  group('Referral model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'REF-001',
        'referredTo': 'District Hospital',
        'speciality': 'Gynaecology',
        'date': '22 Aug 2026',
        'reason': 'Specialist review',
        'status': 'Pending',
      };

      final referral = Referral.fromJson(json);
      expect(referral.id, 'REF-001');
      expect(referral.status, 'Pending');

      final roundtrip = Referral.fromJson(referral.toJson());
      expect(roundtrip.referredTo, 'District Hospital');
    });
  });

  group('HealthcareFacility model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'FAC-001',
        'name': 'PHC Koregaon',
        'type': 'Primary Health Centre',
        'address': 'Main Road',
        'distance': '0.8 km',
        'phone': '02163-123456',
        'hours': 'Mon-Sat: 8am-4pm',
        'isOpen': true,
        'services': ['OPD', 'Lab'],
      };

      final facility = HealthcareFacility.fromJson(json);
      expect(facility.id, 'FAC-001');
      expect(facility.isOpen, true);
      expect(facility.services.length, 2);

      final roundtrip = HealthcareFacility.fromJson(facility.toJson());
      expect(roundtrip.name, 'PHC Koregaon');
      expect(roundtrip.isOpen, true);
    });
  });

  group('Doctor model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'DOC-001',
        'name': 'Dr. Rajesh Kumar',
        'speciality': 'General Physician',
        'qualification': 'MBBS, MD',
        'facility': 'PHC Koregaon',
        'experience': '12 years',
        'availableSlots': 'Today, 10am-1pm',
        'acceptsOnline': true,
      };

      final doctor = Doctor.fromJson(json);
      expect(doctor.id, 'DOC-001');
      expect(doctor.acceptsOnline, true);

      final roundtrip = Doctor.fromJson(doctor.toJson());
      expect(roundtrip.name, 'Dr. Rajesh Kumar');
    });
  });

  group('Consultation model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'CON-001',
        'doctorName': 'Dr. Rajesh Kumar',
        'doctorSpeciality': 'General Physician',
        'facility': 'PHC Koregaon',
        'date': '20 Aug 2026',
        'type': 'In-person',
        'complaints': ['Fatigue', 'Dizziness'],
        'diagnosis': 'Anaemia',
        'plan': 'Iron supplements',
      };

      final consultation = Consultation.fromJson(json);
      expect(consultation.id, 'CON-001');
      expect(consultation.complaints.length, 2);

      final roundtrip = Consultation.fromJson(consultation.toJson());
      expect(roundtrip.diagnosis, 'Anaemia');
    });
  });

  group('MedicalDocument model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'DOC-001',
        'title': 'CBC Test',
        'documentType': 'Lab Report',
        'filePath': '/path/to/file',
        'mimeType': 'application/pdf',
        'fileSize': 1024,
        'uploadedAt': '2026-08-20T10:00:00.000',
      };

      final doc = MedicalDocument.fromJson(json);
      expect(doc.id, 'DOC-001');
      expect(doc.documentType, 'Lab Report');
      expect(doc.fileSize, 1024);

      final roundtrip = MedicalDocument.fromJson(doc.toJson());
      expect(roundtrip.title, 'CBC Test');
      expect(roundtrip.uploadedAt, doc.uploadedAt);
    });
  });

  group('HealthRecord model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': 'HR-001',
        'type': 'Prescription',
        'title': 'Prescription by Dr. Kumar',
        'subtitle': '3 medicines',
        'date': '22 Aug 2026',
        'relatedId': 'RX-001',
      };

      final record = HealthRecord.fromJson(json);
      expect(record.id, 'HR-001');
      expect(record.relatedId, 'RX-001');

      final roundtrip = HealthRecord.fromJson(record.toJson());
      expect(roundtrip.type, 'Prescription');
    });
  });

  group('AiMessage model', () {
    test('fromJson/toJson roundtrip', () {
      final json = {
        'id': '1',
        'text': 'Hello',
        'isAi': true,
        'time': '2026-08-20T10:00:00.000',
      };

      final message = AiMessage.fromJson(json);
      expect(message.id, '1');
      expect(message.isAi, true);

      final roundtrip = AiMessage.fromJson(message.toJson());
      expect(roundtrip.text, 'Hello');
      expect(roundtrip.time, message.time);
    });
  });
}
