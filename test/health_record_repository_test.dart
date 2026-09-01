import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/consultation.dart';
import 'package:ruralcare/core/models/health_record.dart';
import 'package:ruralcare/core/models/lab_report.dart';
import 'package:ruralcare/core/models/prescription.dart';
import 'package:ruralcare/core/models/referral.dart';

void main() {
  group('Phase 4 Health Records Models Test', () {
    test('HealthRecord fromJson and toJson roundtrip', () {
      final json = {
        'id': 'HR-101',
        'type': 'Prescription',
        'title': 'Prescription by Dr. Priya',
        'subtitle': '2 medications',
        'date': '25 Aug 2026',
        'relatedId': 'RX-101',
      };

      final record = HealthRecord.fromJson(json);
      expect(record.id, 'HR-101');
      expect(record.type, 'Prescription');
      expect(record.title, 'Prescription by Dr. Priya');
      expect(record.subtitle, '2 medications');
      expect(record.date, '25 Aug 2026');
      expect(record.relatedId, 'RX-101');

      final serialized = record.toJson();
      expect(serialized['id'], 'HR-101');
      expect(serialized['relatedId'], 'RX-101');
    });

    test('Prescription fromJson parses structured medications and notes', () {
      final json = {
        'id': 'RX-202',
        'doctorName': 'Dr. Priya Sharma',
        'date': '20 Aug 2026',
        'medications': [
          {
            'name': 'Ferrous Sulfate',
            'dosage': '100mg',
            'frequency': 'Once daily',
            'instructions': 'After meals',
          }
        ],
        'notes': 'Take with plenty of water',
      };

      final rx = Prescription.fromJson(json);
      expect(rx.id, 'RX-202');
      expect(rx.doctorName, 'Dr. Priya Sharma');
      expect(rx.medicines.length, 1);
      expect(rx.medicines.first, contains('Ferrous Sulfate'));
      expect(rx.medicines.first, contains('100mg'));
      expect(rx.notes, 'Take with plenty of water');
    });

    test('LabReport fromJson parses results array and abnormal flag', () {
      final json = {
        'id': 'LAB-303',
        'testName': 'Complete Blood Count (CBC)',
        'facilityName': 'Koregaon PHC',
        'date': '22 Aug 2026',
        'resultSummary': 'Low haemoglobin',
        'results': [
          {
            'parameter': 'Haemoglobin',
            'value': '9.8',
            'unit': 'g/dL',
            'isAbnormal': true,
          }
        ],
      };

      final report = LabReport.fromJson(json);
      expect(report.id, 'LAB-303');
      expect(report.testName, 'Complete Blood Count (CBC)');
      expect(report.facility, 'Koregaon PHC');
      expect(report.status, 'Abnormal');
      expect(report.isAbnormal, true);
      expect(report.result, 'Low haemoglobin');
    });

    test('Referral fromJson parses API aliases', () {
      final json = {
        'id': 'REF-404',
        'toFacility': 'Satara District Hospital',
        'specialtyRequired': 'Internal Medicine',
        'referralDate': '15 Aug 2026',
        'reason': 'Evaluation for chronic anaemia',
        'status': 'APPOINTMENT_SCHEDULED',
      };

      final ref = Referral.fromJson(json);
      expect(ref.id, 'REF-404');
      expect(ref.referredTo, 'Satara District Hospital');
      expect(ref.speciality, 'Internal Medicine');
      expect(ref.date, '15 Aug 2026');
      expect(ref.reason, 'Evaluation for chronic anaemia');
      expect(ref.status, 'APPOINTMENT_SCHEDULED');
    });

    test('Consultation fromJson parses symptoms and doctor notes', () {
      final json = {
        'id': 'CON-505',
        'doctorName': 'Dr. Rajesh Kumar',
        'doctorSpecialty': 'General Physician',
        'facilityName': 'Koregaon PHC',
        'date': '10 Aug 2026',
        'type': 'IN_PERSON',
        'symptoms': ['Fatigue', 'Dizziness'],
        'diagnosis': 'Iron Deficiency Anaemia',
        'doctorNotes': 'Advised oral iron supplementation.',
      };

      final con = Consultation.fromJson(json);
      expect(con.id, 'CON-505');
      expect(con.doctorName, 'Dr. Rajesh Kumar');
      expect(con.doctorSpeciality, 'General Physician');
      expect(con.facility, 'Koregaon PHC');
      expect(con.complaints, ['Fatigue', 'Dizziness']);
      expect(con.diagnosis, 'Iron Deficiency Anaemia');
      expect(con.plan, 'Advised oral iron supplementation.');
    });
  });
}
