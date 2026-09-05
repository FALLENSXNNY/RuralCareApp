import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/location_service.dart';
import '../data/healthcare_repository.dart';
import '../models/healthcare_place.dart';

/// State of the Healthcare Finder module
class HealthcareFinderState {
  final bool isLoading;
  final bool isPermissionLoading;
  final LocationPermissionStatus locationStatus;
  final UserLocation? userLocation;
  final String selectedCategory;
  final String searchQuery;
  final HealthcareSortOption sortOption;
  final List<HealthcarePlace> places;
  final HealthcarePlace? selectedPlace;
  final String? errorMessage;
  final bool isEmergencyMode;

  const HealthcareFinderState({
    this.isLoading = false,
    this.isPermissionLoading = false,
    this.locationStatus = LocationPermissionStatus.unknown,
    this.userLocation,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.sortOption = HealthcareSortOption.distance,
    this.places = const [],
    this.selectedPlace,
    this.errorMessage,
    this.isEmergencyMode = false,
  });

  HealthcareFinderState copyWith({
    bool? isLoading,
    bool? isPermissionLoading,
    LocationPermissionStatus? locationStatus,
    UserLocation? userLocation,
    String? selectedCategory,
    String? searchQuery,
    HealthcareSortOption? sortOption,
    List<HealthcarePlace>? places,
    HealthcarePlace? selectedPlace,
    String? errorMessage,
    bool? isEmergencyMode,
    bool clearSelectedPlace = false,
    bool clearErrorMessage = false,
  }) {
    return HealthcareFinderState(
      isLoading: isLoading ?? this.isLoading,
      isPermissionLoading: isPermissionLoading ?? this.isPermissionLoading,
      locationStatus: locationStatus ?? this.locationStatus,
      userLocation: userLocation ?? this.userLocation,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      sortOption: sortOption ?? this.sortOption,
      places: places ?? this.places,
      selectedPlace:
          clearSelectedPlace ? null : (selectedPlace ?? this.selectedPlace),
      errorMessage:
          clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      isEmergencyMode: isEmergencyMode ?? this.isEmergencyMode,
    );
  }
}

/// Provider for HealthcareFinderRepository
final healthcareFinderRepoProvider = Provider<HealthcareFinderRepository>((ref) {
  return HealthcareFinderRepository();
});

/// Provider for LocationService
final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

/// StateNotifier provider for Healthcare Finder
final healthcareFinderProvider =
    StateNotifierProvider.autoDispose<HealthcareFinderNotifier, HealthcareFinderState>((ref) {
  final repo = ref.watch(healthcareFinderRepoProvider);
  final locService = ref.watch(locationServiceProvider);
  return HealthcareFinderNotifier(repo, locService);
});

class HealthcareFinderNotifier extends StateNotifier<HealthcareFinderState> {
  final HealthcareFinderRepository _repository;
  final LocationService _locationService;

  HealthcareFinderNotifier(
    this._repository,
    this._locationService,
  ) : super(const HealthcareFinderState()) {
    initialize();
  }

  /// Initial load and GPS permission check
  Future<void> initialize({
    String initialCategory = 'All',
    bool isEmergency = false,
  }) async {
    state = state.copyWith(
      isLoading: true,
      selectedCategory: initialCategory,
      isEmergencyMode: isEmergency,
      clearErrorMessage: true,
    );

    await requestLocationAndSearch();
  }

  /// Checks location permission, gets GPS coords, and fetches facilities
  Future<void> requestLocationAndSearch() async {
    state = state.copyWith(isPermissionLoading: true);

    try {
      final status = await _locationService.checkPermission();
      UserLocation? location;

      if (status == LocationPermissionStatus.granted) {
        location = await _locationService.getCurrentLocation();
      }

      state = state.copyWith(
        locationStatus: status,
        userLocation: location,
        isPermissionLoading: false,
      );

      await searchPlaces();
    } catch (e) {
      state = state.copyWith(
        isPermissionLoading: false,
        errorMessage: e.toString(),
      );
      await searchPlaces();
    }
  }

  /// Requests permission directly (e.g. from banner or locate me button)
  Future<void> requestPermission() async {
    state = state.copyWith(isPermissionLoading: true);
    final status = await _locationService.requestPermission();
    
    UserLocation? location;
    if (status == LocationPermissionStatus.granted) {
      location = await _locationService.getCurrentLocation();
    }

    state = state.copyWith(
      locationStatus: status,
      userLocation: location,
      isPermissionLoading: false,
    );

    await searchPlaces();
  }

  /// Searches places with active filters
  Future<void> searchPlaces() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final results = await _repository.getHealthcarePlaces(
        userLocation: state.userLocation,
        category: state.selectedCategory,
        searchQuery: state.searchQuery,
        sortOption: state.sortOption,
        isEmergencyMode: state.isEmergencyMode,
      );

      state = state.copyWith(
        isLoading: false,
        places: results,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  /// Changes category filter
  void setCategory(String category) {
    if (state.selectedCategory == category) return;
    state = state.copyWith(selectedCategory: category);
    searchPlaces();
  }

  /// Sets text search query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    searchPlaces();
  }

  /// Changes sorting option
  void setSortOption(HealthcareSortOption option) {
    if (state.sortOption == option) return;
    state = state.copyWith(sortOption: option);
    searchPlaces();
  }

  /// Selects a facility for preview
  void selectPlace(HealthcarePlace place) {
    state = state.copyWith(selectedPlace: place);
  }

  /// Clears selected preview
  void clearSelectedPlace() {
    state = state.copyWith(clearSelectedPlace: true);
  }

  /// Searches for healthcare facilities at specified coordinates / custom area
  Future<void> searchAtCoordinates(
    double latitude,
    double longitude, {
    String? areaName,
  }) async {
    state = state.copyWith(
      userLocation: UserLocation(
        latitude: latitude,
        longitude: longitude,
        placename: areaName ?? 'Selected Area',
        timestamp: DateTime.now(),
      ),
    );
    await searchPlaces();
  }
}
