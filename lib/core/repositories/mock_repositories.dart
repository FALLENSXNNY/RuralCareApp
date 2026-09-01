import '../mock/mock_patient_data.dart';
import '../models/ai_message.dart';
import '../models/consultation.dart';
import '../models/doctor.dart';
import '../models/facility.dart';
import '../models/health_record.dart';
import '../models/lab_report.dart';
import '../models/medical_document.dart';
import '../models/patient.dart';
import '../models/prescription.dart';
import '../models/referral.dart';
import 'ai_repository.dart';
import 'document_repository.dart';
import 'facility_repository.dart';
import 'health_record_repository.dart';
import 'patient_repository.dart';

/// Mock implementation of [PatientRepository].
class MockPatientRepository implements PatientRepository {
  Patient _patient = MockPatientData.currentPatient;

  @override
  Future<Patient> getCurrentPatient() async => _patient;

  @override
  Future<Patient> updatePatient(Patient patient) async {
    _patient = patient;
    return _patient;
  }

  @override
  Future<void> savePatientLocally(Patient patient) async {
    _patient = patient;
  }

  @override
  Patient? getLocalPatient() => _patient;
}

/// Mock implementation of [HealthRecordRepository].
class MockHealthRecordRepository implements HealthRecordRepository {
  final List<Prescription> _prescriptions = MockPatientData.prescriptions;
  final List<LabReport> _labReports = MockPatientData.labReports;
  final List<Referral> _referrals = MockPatientData.referrals;
  final List<Consultation> _consultations = MockPatientData.consultations;

  @override
  Future<List<HealthRecord>> getHealthTimeline() async {
    final list = <HealthRecord>[
      ..._prescriptions.map((p) => HealthRecord(
            id: p.id,
            title: 'Prescription: ${p.doctorName}',
            type: 'Prescription',
            date: p.date,
            subtitle: p.medicines.join(', '),
            relatedId: p.id,
          )),
      ..._labReports.map((l) => HealthRecord(
            id: l.id,
            title: l.testName,
            type: 'Lab Report',
            date: l.date,
            subtitle: '${l.result} • ${l.status}',
            relatedId: l.id,
          )),
      ..._referrals.map((r) => HealthRecord(
            id: r.id,
            title: 'Referral: ${r.speciality}',
            type: 'Referral',
            date: r.date,
            subtitle: '${r.referredTo} (${r.status})',
            relatedId: r.id,
          )),
      ..._consultations.map((c) => HealthRecord(
            id: c.id,
            title: 'Consultation: ${c.doctorName}',
            type: 'Consultation',
            date: c.date,
            subtitle: '${c.facility} • ${c.diagnosis}',
            relatedId: c.id,
          )),
    ];
    return list;
  }

  @override
  Future<List<Prescription>> getPrescriptions() async => _prescriptions;

  @override
  Future<Prescription> getPrescription(String id) async {
    return _prescriptions.firstWhere(
      (p) => p.id == id,
      orElse: () => _prescriptions.first,
    );
  }

  @override
  Future<List<LabReport>> getLabReports() async => _labReports;

  @override
  Future<LabReport> getLabReport(String id) async {
    return _labReports.firstWhere(
      (l) => l.id == id,
      orElse: () => _labReports.first,
    );
  }

  @override
  Future<List<Referral>> getReferrals() async => _referrals;

  @override
  Future<Referral> getReferral(String id) async {
    return _referrals.firstWhere(
      (r) => r.id == id,
      orElse: () => _referrals.first,
    );
  }

  @override
  Future<List<Consultation>> getConsultations() async => _consultations;

  @override
  Future<Consultation> getConsultation(String id) async {
    return _consultations.firstWhere(
      (c) => c.id == id,
      orElse: () => _consultations.first,
    );
  }
}

/// Mock implementation of [FacilityRepository].
class MockFacilityRepository implements FacilityRepository {
  final List<HealthcareFacility> _facilities = MockPatientData.facilities;
  final List<Doctor> _doctors = MockPatientData.doctors;

  @override
  Future<List<HealthcareFacility>> getFacilities() async => _facilities;

  @override
  Future<List<HealthcareFacility>> searchFacilities(String query) async {
    final lower = query.toLowerCase();
    return _facilities
        .where((f) =>
            f.name.toLowerCase().contains(lower) ||
            f.address.toLowerCase().contains(lower) ||
            f.services.any((s) => s.toLowerCase().contains(lower)))
        .toList();
  }

  @override
  Future<List<HealthcareFacility>> getFacilitiesByType(String type) async {
    return _facilities
        .where((f) => f.type.toLowerCase() == type.toLowerCase())
        .toList();
  }

  @override
  Future<List<Doctor>> getDoctors() async => _doctors;

  @override
  Future<Doctor> getDoctor(String id) async {
    return _doctors.firstWhere(
      (d) => d.id == id,
      orElse: () => _doctors.first,
    );
  }
}

/// Mock implementation of [DocumentRepository].
class MockDocumentRepository implements DocumentRepository {
  final List<MedicalDocument> _documents = [];

  @override
  Future<List<MedicalDocument>> getDocuments({String? type}) async {
    if (type != null && type.isNotEmpty && type != 'All') {
      return List.unmodifiable(
          _documents.where((d) => d.documentType == type).toList());
    }
    return List.unmodifiable(_documents);
  }

  @override
  Future<MedicalDocument> getDocument(String id) async {
    final docs = await getDocuments();
    return docs.firstWhere(
      (d) => d.id == id,
      orElse: () => MedicalDocument(
        id: id,
        title: 'Medical Document #$id',
        documentType: 'Prescription',
        uploadedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<MedicalDocument> saveDocument(MedicalDocument document) async {
    _documents.add(document);
    return document;
  }

  @override
  Future<void> deleteDocument(String id) async {
    _documents.removeWhere((d) => d.id == id);
  }
}

/// Mock implementation of [AIRepository].
/// This provides safe, controlled responses that follow AI_SAFETY.md.
class MockAIRepository implements AIRepository {
  final List<AiMessage> _history = [];

  @override
  Future<AiMessage> sendMessage(
    String message, {
    List<AiMessage>? history,
  }) async {
    // Simulate realistic response time
    await Future.delayed(const Duration(milliseconds: 600));

    final reply = AiMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'Thank you for your question. Here is health guidance for your consideration:\n\n'
          '• Rest in a quiet space and drink plenty of clean, safe water.\n'
          '• Monitor your symptoms closely over the next 24 hours.\n'
          '• If symptoms worsen or persist, please visit your local Primary Health Centre (PHC Koregaon).\n\n'
          '**Important Notice:** This is general health information, not a formal medical diagnosis. Please consult a doctor or healthcare worker.',
      isAi: true,
      time: DateTime.now(),
    );

    _history.add(AiMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_u',
      text: message,
      isAi: false,
      time: DateTime.now(),
    ));
    _history.add(reply);

    return reply;
  }

  @override
  Future<List<AiMessage>> getConversationHistory() async {
    return List.unmodifiable(_history);
  }

  @override
  Future<void> clearConversationHistory() async {
    _history.clear();
  }
}
