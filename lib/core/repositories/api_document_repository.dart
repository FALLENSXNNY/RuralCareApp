// Real API-backed implementation of DocumentRepository for Phase 8.
// Communicates with backend endpoints (/documents) using bearer auth
// and automatically falls back to MockDocumentRepository on network errors or offline mode.
import '../error/app_exception.dart';
import '../models/medical_document.dart';
import '../networking/api_client.dart';
import '../repositories/mock_repositories.dart';
import '../services/firebase_auth_service.dart';
import 'document_repository.dart';

class ApiDocumentRepository implements DocumentRepository {
  ApiDocumentRepository(ApiClient apiClient, FirebaseAuthService authService)
      : _apiClient = apiClient,
        _authService = authService,
        _fallback = MockDocumentRepository();

  final ApiClient _apiClient;
  final FirebaseAuthService _authService;
  final MockDocumentRepository _fallback;

  Future<String> _getIdToken() async {
    final user = _authService.currentUser;
    if (user == null) {
      throw AppException.authentication('You are not signed in.');
    }
    String? token = await user.getIdToken(false);
    if (token == null || token.isEmpty) {
      token = await user.getIdToken(true);
    }
    if (token == null || token.isEmpty) {
      throw AppException.authentication('Could not obtain session token.');
    }
    return token;
  }

  @override
  Future<List<MedicalDocument>> getDocuments({String? type}) async {
    try {
      final token = await _getIdToken();
      final endpoint = (type != null && type.isNotEmpty && type != 'All')
          ? '/documents?type=${Uri.encodeComponent(type)}'
          : '/documents';

      final response = await _apiClient.request(
        endpoint,
        method: ApiMethod.get,
        authToken: token,
      );

      if (!response.isSuccess || response.data == null) {
        return await _fallback.getDocuments();
      }

      final data = response.data;
      if (data is Map<String, dynamic> && data['documents'] is List) {
        final list = (data['documents'] as List)
            .map((item) =>
                MedicalDocument.fromJson(item as Map<String, dynamic>))
            .toList();
        return list;
      }

      return await _fallback.getDocuments();
    } catch (_) {
      return await _fallback.getDocuments();
    }
  }

  @override
  Future<MedicalDocument> saveDocument(MedicalDocument document) async {
    try {
      final token = await _getIdToken();
      final payload = document.toJson();

      final response = await _apiClient.request(
        '/documents',
        method: ApiMethod.post,
        body: payload,
        authToken: token,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['document'] is Map) {
          return MedicalDocument.fromJson(
              data['document'] as Map<String, dynamic>);
        }
      }

      return await _fallback.saveDocument(document);
    } catch (_) {
      return await _fallback.saveDocument(document);
    }
  }

  @override
  Future<void> deleteDocument(String id) async {
    try {
      final token = await _getIdToken();
      final response = await _apiClient.request(
        '/documents/$id',
        method: ApiMethod.delete,
        authToken: token,
      );

      if (!response.isSuccess) {
        await _fallback.deleteDocument(id);
      }
    } catch (_) {
      await _fallback.deleteDocument(id);
    }
  }

  @override
  Future<MedicalDocument> getDocument(String id) async {
    try {
      final token = await _getIdToken();
      final response = await _apiClient.request(
        '/documents/$id',
        method: ApiMethod.get,
        authToken: token,
      );

      if (response.isSuccess && response.data != null) {
        final data = response.data;
        if (data is Map<String, dynamic> && data['document'] is Map) {
          return MedicalDocument.fromJson(
              data['document'] as Map<String, dynamic>);
        }
      }

      return await _fallback.getDocument(id);
    } catch (_) {
      return await _fallback.getDocument(id);
    }
  }
}
