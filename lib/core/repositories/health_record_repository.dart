// Health record repository — abstraction for patient health records
import '../models/consultation.dart';
import '../models/health_record.dart';
import '../models/lab_report.dart';
import '../models/prescription.dart';
import '../models/referral.dart';

abstract class HealthRecordRepository {
  /// Returns the patient's health timeline.
  Future<List<HealthRecord>> getHealthTimeline();

  /// Returns all prescriptions.
  Future<List<Prescription>> getPrescriptions();

  /// Returns a single prescription by ID.
  Future<Prescription> getPrescription(String id);

  /// Returns all lab reports.
  Future<List<LabReport>> getLabReports();

  /// Returns a single lab report by ID.
  Future<LabReport> getLabReport(String id);

  /// Returns all referrals.
  Future<List<Referral>> getReferrals();

  /// Returns a single referral by ID.
  Future<Referral> getReferral(String id);

  /// Returns all consultations.
  Future<List<Consultation>> getConsultations();

  /// Returns a single consultation by ID.
  Future<Consultation> getConsultation(String id);
}
