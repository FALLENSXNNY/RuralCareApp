import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ruralcare/core/models/consultation.dart';
import 'package:ruralcare/core/models/lab_report.dart';
import 'package:ruralcare/core/models/medical_document.dart';
import 'package:ruralcare/core/models/prescription.dart';
import 'package:ruralcare/core/models/referral.dart';
import 'package:ruralcare/core/providers/app_providers.dart';
import 'package:ruralcare/core/repositories/mock_repositories.dart';

void main() {
  group('Phase 9 — Health Records & Documents Providers Test', () {
    test('prescriptionsProvider and prescriptionDetailProvider resolve correctly', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(MockHealthRecordRepository()),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(prescriptionsProvider.future);
      expect(list, isNotEmpty);
      expect(list.first, isA<Prescription>());

      final firstId = list.first.id;
      final single = await container.read(prescriptionDetailProvider(firstId).future);
      expect(single.id, equals(firstId));
      expect(single.doctorName, isNotEmpty);
      expect(single.medicines, isNotEmpty);
    });

    test('labReportsProvider and labReportDetailProvider resolve correctly', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(MockHealthRecordRepository()),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(labReportsProvider.future);
      expect(list, isNotEmpty);
      expect(list.first, isA<LabReport>());

      final firstId = list.first.id;
      final single = await container.read(labReportDetailProvider(firstId).future);
      expect(single.id, equals(firstId));
      expect(single.testName, isNotEmpty);
      expect(single.result, isNotEmpty);
    });

    test('referralsProvider and referralDetailProvider resolve correctly', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(MockHealthRecordRepository()),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(referralsProvider.future);
      expect(list, isNotEmpty);
      expect(list.first, isA<Referral>());

      final firstId = list.first.id;
      final single = await container.read(referralDetailProvider(firstId).future);
      expect(single.id, equals(firstId));
      expect(single.referredTo, isNotEmpty);
      expect(single.status, isNotEmpty);
    });

    test('consultationsProvider and consultationDetailProvider resolve correctly', () async {
      final container = ProviderContainer(
        overrides: [
          healthRecordRepositoryProvider.overrideWithValue(MockHealthRecordRepository()),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(consultationsProvider.future);
      expect(list, isNotEmpty);
      expect(list.first, isA<Consultation>());

      final firstId = list.first.id;
      final single = await container.read(consultationDetailProvider(firstId).future);
      expect(single.id, equals(firstId));
      expect(single.doctorName, isNotEmpty);
    });

    test('patientDocumentsProvider and documentDetailProvider resolve correctly', () async {
      final mockRepo = MockDocumentRepository();
      await mockRepo.saveDocument(
        MedicalDocument(
          id: 'DOC-101',
          title: 'Prescription Dr. Sharma',
          documentType: 'Prescription',
          uploadedAt: DateTime.now(),
        ),
      );

      final container = ProviderContainer(
        overrides: [
          documentRepositoryProvider.overrideWithValue(mockRepo),
        ],
      );
      addTearDown(container.dispose);

      final list = await container.read(patientDocumentsProvider(null).future);
      expect(list, isNotEmpty);
      expect(list.first, isA<MedicalDocument>());

      final firstId = list.first.id;
      final single = await container.read(documentDetailProvider(firstId).future);
      expect(single.id, equals(firstId));
      expect(single.title, isNotEmpty);
    });
  });
}
