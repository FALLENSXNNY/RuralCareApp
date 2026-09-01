// Document repository — abstraction for medical document storage
import '../models/medical_document.dart';

abstract class DocumentRepository {
  /// Returns all documents for the current patient, optionally filtered by type.
  Future<List<MedicalDocument>> getDocuments({String? type});

  /// Returns a single document by ID.
  Future<MedicalDocument> getDocument(String id);

  /// Saves a document locally.
  Future<MedicalDocument> saveDocument(MedicalDocument document);

  /// Deletes a document by ID.
  Future<void> deleteDocument(String id);
}
