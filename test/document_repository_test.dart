import 'package:flutter_test/flutter_test.dart';
import 'package:ruralcare/core/models/medical_document.dart';
import 'package:ruralcare/core/repositories/mock_repositories.dart';

void main() {
  group('Phase 8 Medical Documents — Model & Repository Tests', () {
    test('MedicalDocument fromJson and toJson roundtrip', () {
      final now = DateTime(2026, 8, 31, 12, 0, 0);
      final doc = MedicalDocument(
        id: 'doc-123',
        title: 'Prescription for Fever',
        documentType: 'Prescription',
        filePath: 'prescription_aug_2026.jpg',
        fileUrl: 'https://storage.ruralcare.in/docs/prescription.jpg',
        fileData: 'sample_base64_data',
        mimeType: 'image/jpeg',
        fileSize: 1024 * 512, // 512 KB
        notes: 'Prescribed by Dr. Patel',
        uploadedAt: now,
      );

      final json = doc.toJson();
      expect(json['id'], 'doc-123');
      expect(json['title'], 'Prescription for Fever');
      expect(json['documentType'], 'Prescription');
      expect(json['fileSize'], 524288);
      expect(json['notes'], 'Prescribed by Dr. Patel');

      final reconstructed = MedicalDocument.fromJson(json);
      expect(reconstructed.id, doc.id);
      expect(reconstructed.title, doc.title);
      expect(reconstructed.documentType, doc.documentType);
      expect(reconstructed.fileSize, doc.fileSize);
      expect(reconstructed.notes, doc.notes);
      expect(reconstructed.formattedFileSize, '512.0 KB');
    });

    test('MedicalDocument formattedFileSize handles sizes correctly', () {
      final docBytes = MedicalDocument(
        id: '1',
        title: 'Small',
        documentType: 'Other',
        fileSize: 500,
        uploadedAt: DateTime.now(),
      );
      expect(docBytes.formattedFileSize, '500 B');

      final docMb = MedicalDocument(
        id: '2',
        title: 'Scan',
        documentType: 'X-Ray / Scan',
        fileSize: 3 * 1024 * 1024,
        uploadedAt: DateTime.now(),
      );
      expect(docMb.formattedFileSize, '3.0 MB');

      final docNull = MedicalDocument(
        id: '3',
        title: 'Unknown',
        documentType: 'Other',
        fileSize: null,
        uploadedAt: DateTime.now(),
      );
      expect(docNull.formattedFileSize, 'Unknown size');
    });

    test('MockDocumentRepository saves, filters, and deletes documents', () async {
      final repo = MockDocumentRepository();

      expect(await repo.getDocuments(), isEmpty);

      final doc1 = MedicalDocument(
        id: 'd1',
        title: 'Blood Test Report',
        documentType: 'Lab Report',
        fileSize: 1024 * 100,
        uploadedAt: DateTime.now(),
      );

      final doc2 = MedicalDocument(
        id: 'd2',
        title: 'Chest X-Ray',
        documentType: 'X-Ray / Scan',
        fileSize: 1024 * 1024 * 2,
        uploadedAt: DateTime.now(),
      );

      await repo.saveDocument(doc1);
      await repo.saveDocument(doc2);

      final allDocs = await repo.getDocuments();
      expect(allDocs.length, 2);

      final labDocs = await repo.getDocuments(type: 'Lab Report');
      expect(labDocs.length, 1);
      expect(labDocs.first.title, 'Blood Test Report');

      await repo.deleteDocument('d1');
      final remaining = await repo.getDocuments();
      expect(remaining.length, 1);
      expect(remaining.first.id, 'd2');
    });
  });
}
