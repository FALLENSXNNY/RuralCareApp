import '../../../core/networking/api_client.dart';
import '../models/healthcare_place.dart';
import '../models/place_details.dart';

/// Service for communicating with backend Google Places API endpoints
class GooglePlacesService {
  final ApiClient _apiClient;

  GooglePlacesService({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  /// Fetches nearby healthcare facilities from the backend
  Future<List<HealthcarePlace>> fetchNearbyHealthcare({
    required double latitude,
    required double longitude,
    double radius = 25000,
    String category = 'all',
  }) async {
    final queryParams =
        'latitude=$latitude&longitude=$longitude&radius=${radius.toInt()}&category=${Uri.encodeComponent(category)}';
    
    final response = await _apiClient.request(
      '/healthcare/nearby?$queryParams',
      method: ApiMethod.get,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'];
      if (data is List) {
        return data
            .map((item) =>
                HealthcarePlace.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    }
    return [];
  }

  /// Fetches detailed facility metadata from backend
  Future<PlaceDetails?> fetchPlaceDetails(String placeId) async {
    final response = await _apiClient.request(
      '/healthcare/details/${Uri.encodeComponent(placeId)}',
      method: ApiMethod.get,
    );

    if (response.isSuccess && response.data != null) {
      final data = response.data!['data'];
      if (data is Map<String, dynamic>) {
        return PlaceDetails.fromJson(data);
      }
    }
    return null;
  }
}
