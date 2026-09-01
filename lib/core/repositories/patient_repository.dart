// Patient repository — abstraction for patient data access
import '../models/patient.dart';

abstract class PatientRepository {
  /// Returns the current patient's profile.
  Future<Patient> getCurrentPatient();

  /// Updates the current patient's profile.
  Future<Patient> updatePatient(Patient patient);

  /// Saves the patient profile locally.
  Future<void> savePatientLocally(Patient patient);

  /// Returns the locally cached patient profile, if any.
  Patient? getLocalPatient();
}
