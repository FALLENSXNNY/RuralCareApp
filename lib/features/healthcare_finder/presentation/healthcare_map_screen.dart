import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../controller/healthcare_controller.dart';
import '../data/directions_service.dart';
import '../data/healthcare_repository.dart';
import '../models/healthcare_place.dart';
import '../widgets/category_chip.dart';
import '../widgets/floating_location_button.dart';
import '../widgets/healthcare_card.dart';
import '../widgets/interactive_map_view.dart';

class HealthcareMapScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final bool isEmergencyMode;

  const HealthcareMapScreen({
    super.key,
    this.initialCategory,
    this.isEmergencyMode = false,
  });

  @override
  ConsumerState<HealthcareMapScreen> createState() =>
      _HealthcareMapScreenState();
}

class _HealthcareMapScreenState extends ConsumerState<HealthcareMapScreen> {
  final TextEditingController _searchController = TextEditingController();
  final DirectionsService _directionsService = DirectionsService();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  double _sheetSize = 0.42;

  @override
  void initState() {
    super.initState();
    _sheetController.addListener(_onSheetSizeChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthcareFinderProvider.notifier).initialize(
            initialCategory: widget.initialCategory ?? 'All',
            isEmergency: widget.isEmergencyMode,
          );
    });
  }

  @override
  void didUpdateWidget(covariant HealthcareMapScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCategory != oldWidget.initialCategory &&
        widget.initialCategory != null) {
      ref
          .read(healthcareFinderProvider.notifier)
          .setCategory(widget.initialCategory!);
    }
  }

  void _onSheetSizeChanged() {
    if (mounted && _sheetController.isAttached) {
      final current = _sheetController.size;
      if ((current - _sheetSize).abs() > 0.02) {
        setState(() {
          _sheetSize = current;
        });
      }
    }
  }

  @override
  void dispose() {
    _sheetController.removeListener(_onSheetSizeChanged);
    _sheetController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onCategorySelected(String category) {
    ref.read(healthcareFinderProvider.notifier).setCategory(category);
  }

  void _onSearchChanged(String query) {
    ref.read(healthcareFinderProvider.notifier).setSearchQuery(query);
  }

  void _onPlaceTap(HealthcarePlace place) {
    context.push('/healthcare-details/${place.id}', extra: place);
  }

  void _onDirections(HealthcarePlace place) {
    context.push('/directions', extra: place);
  }

  void _onCall(HealthcarePlace place) {
    if (place.phone.isNotEmpty) {
      _directionsService.launchPhoneCall(place.phone);
    }
  }

  void _onBookAppointment(HealthcarePlace place) {
    context.push(AppRoutes.bookAppointment, extra: place);
  }

  /// Toggles the facility finding section between expanded and collapsed positions
  void _toggleSheetPosition() {
    if (!_sheetController.isAttached) return;
    final current = _sheetController.size;
    if (current >= 0.65) {
      // If fully expanded, move down to half-height (0.42)
      _sheetController.animateTo(
        0.42,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else if (current >= 0.28) {
      // If at half-height, expand up to full-height (0.88)
      _sheetController.animateTo(
        0.88,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      // If collapsed at bottom, expand up to half-height (0.42)
      _sheetController.animateTo(
        0.42,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final state = ref.watch(healthcareFinderProvider);
    final notifier = ref.read(healthcareFinderProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          tooltip: loc.translate('back'),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          loc.translate('nearbyHealthcare'),
          style: AppTextStyles.titleMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: widget.isEmergencyMode
            ? AppColors.emergencyRed
            : AppColors.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: Colors.white),
            tooltip: loc.translate('myAppointments'),
            onPressed: () => context.push(AppRoutes.myAppointments),
          ),
          IconButton(
            icon: const Icon(Icons.confirmation_number_rounded, color: Colors.white),
            tooltip: loc.translate('myQueue'),
            onPressed: () => context.push(AppRoutes.liveQueue),
          ),
          // Sort Menu
          PopupMenuButton<HealthcareSortOption>(
            icon: const Icon(Icons.sort_rounded, color: Colors.white),
            tooltip: loc.translate('sort'),
            onSelected: (option) => notifier.setSortOption(option),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: HealthcareSortOption.distance,
                child: Row(
                  children: [
                    const Icon(Icons.near_me_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.translate('distance')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HealthcareSortOption.rating,
                child: Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.translate('rating')),
                  ],
                ),
              ),
              PopupMenuItem(
                value: HealthcareSortOption.openNow,
                child: Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 18),
                    const SizedBox(width: 8),
                    Text(loc.translate('openNow')),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Search & Category Filters Bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
            child: Column(
              children: [
                // Search Input
                Container(
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusFull),
                    border: Border.all(
                      color: AppColors.outlineVariant.withOpacity(0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: loc.translate('searchFacilitiesHint'),
                      hintStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding:
                          const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Category Chips: Structured into 2 symmetrical rows
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Row 1: General & Priority Categories (3 items)
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: HealthcareCategoryChip(
                            label: loc.translate('allCategories'),
                            icon: Icons.grid_view_rounded,
                            isSelected:
                                state.selectedCategory.toLowerCase() == 'all',
                            onTap: () => _onCategorySelected('All'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 5,
                          child: HealthcareCategoryChip(
                            label: loc.translate('emergencyCategory'),
                            icon: Icons.emergency_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'emergency' ||
                                state.selectedCategory.toLowerCase() ==
                                    '24x7 emergency',
                            isEmergency: true,
                            onTap: () => _onCategorySelected('Emergency'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          flex: 5,
                          child: HealthcareCategoryChip(
                            label: loc.translate('maternalCare'),
                            icon: Icons.pregnant_woman_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'maternal care' ||
                                state.selectedCategory.toLowerCase() ==
                                    'maternity',
                            onTap: () => _onCategorySelected('Maternal Care'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Row 2: Facility & Provider Specific Types (4 items)
                    Row(
                      children: [
                        Expanded(
                          child: HealthcareCategoryChip(
                            label: loc.translate('hospitals'),
                            icon: Icons.local_hospital_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'hospitals' ||
                                state.selectedCategory.toLowerCase() ==
                                    'hospital',
                            onTap: () => _onCategorySelected('Hospitals'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: HealthcareCategoryChip(
                            label: loc.translate('clinics'),
                            icon: Icons.medical_services_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'clinics' ||
                                state.selectedCategory.toLowerCase() ==
                                    'clinic',
                            onTap: () => _onCategorySelected('Clinics'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: HealthcareCategoryChip(
                            label: loc.translate('doctors'),
                            icon: Icons.person_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'doctors' ||
                                state.selectedCategory.toLowerCase() ==
                                    'doctor',
                            onTap: () => _onCategorySelected('Doctors'),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: HealthcareCategoryChip(
                            label: loc.translate('pharmacies'),
                            icon: Icons.local_pharmacy_rounded,
                            isSelected: state.selectedCategory.toLowerCase() ==
                                    'pharmacies' ||
                                state.selectedCategory.toLowerCase() ==
                                    'pharmacy',
                            onTap: () => _onCategorySelected('Pharmacies'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Area Selection Banner
                InkWell(
                  onTap: () => _openAreaSelectorModal(context, notifier, state),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            state.userLocation?.placename ??
                                loc.translate('detectedLocation'),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius:
                                BorderRadius.circular(AppDimensions.radiusFull),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.tune_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                loc.translate('changeArea'),
                                style: AppTextStyles.labelSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Main Content: Interactive Map with Floating Interactive Bottom Sheet
          Expanded(
            child: Stack(
              children: [
                // 1. Interactive Google Map (fills entire background)
                Positioned.fill(
                  child: InteractiveHealthcareMapView(
                    userLocation: state.userLocation,
                    places: state.places,
                    selectedPlace: state.selectedPlace,
                    onPlaceSelected: (place) {
                      notifier.selectPlace(place);
                      if (_sheetController.isAttached &&
                          _sheetController.size < 0.35) {
                        _sheetController.animateTo(
                          0.42,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                        );
                      }
                    },
                    onPlaceDetailsTap: (place) {
                      _onPlaceTap(place);
                    },
                    onRecenter: () => notifier.requestLocationAndSearch(),
                    isRecenterLoading: state.isPermissionLoading,
                    onSearchThisArea: (center) {
                      notifier.searchAtCoordinates(
                        center.latitude,
                        center.longitude,
                        areaName: 'Selected Map Location',
                      );
                    },
                  ),
                ),

                // 2. Floating "Locate Me" Button (positioned top-right of map)
                Positioned(
                  top: 14,
                  right: 16,
                  child: FloatingLocationButton(
                    onTap: () => notifier.requestLocationAndSearch(),
                    isLoading: state.isPermissionLoading,
                  ),
                ),

                // 3. Interactive Draggable & Animated Facility Finding Section
                DraggableScrollableSheet(
                  controller: _sheetController,
                  initialChildSize: 0.42,
                  minChildSize: 0.14,
                  maxChildSize: 0.88,
                  snap: true,
                  snapSizes: const [0.14, 0.42, 0.88],
                  builder: (context, scrollController) {
                    return Container(
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(22),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 14,
                            spreadRadius: 1,
                            offset: const Offset(0, -3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // FIXED Top Header with Drag Handle & Interactive Up/Down Toggle Button
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: _toggleSheetPosition,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(22),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 10, 16, 8),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Top Handle Bar Pill
                                    Container(
                                      width: 44,
                                      height: 5,
                                      decoration: BoxDecoration(
                                        color: AppColors.outlineVariant,
                                        borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusFull,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Interactive Header: Results Count + Up/Down Button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Left: Facility count and GPS active badge
                                        Row(
                                          children: [
                                            Text(
                                              '${state.places.length} ${loc.translate('facilitiesFound')}',
                                              style: AppTextStyles
                                                  .labelLarge
                                                  .copyWith(
                                                color: AppColors.onSurface,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            if (state.userLocation != null)
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.healthGreen
                                                      .withOpacity(0.12),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppDimensions
                                                              .radiusFull),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons
                                                          .location_on_rounded,
                                                      size: 12,
                                                      color: AppColors
                                                          .healthGreen,
                                                    ),
                                                    const SizedBox(width: 3),
                                                    Text(
                                                      loc.translate(
                                                          'gpsActive'),
                                                      style: AppTextStyles
                                                          .labelSmall
                                                          .copyWith(
                                                        color: AppColors
                                                            .healthGreen,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),

                                        // Right: Interactive Button to Move Up / Down
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary
                                                .withOpacity(0.1),
                                            borderRadius:
                                                BorderRadius.circular(
                                              AppDimensions.radiusFull,
                                            ),
                                            border: Border.all(
                                              color: AppColors.primary
                                                  .withOpacity(0.25),
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                _sheetSize >= 0.65
                                                    ? Icons
                                                        .keyboard_arrow_down_rounded
                                                    : Icons
                                                        .keyboard_arrow_up_rounded,
                                                size: 18,
                                                color: AppColors.primary,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _sheetSize >= 0.65
                                                    ? loc.translate('showMap')
                                                    : loc.translate(
                                                        'showList'),
                                                style: AppTextStyles
                                                    .labelSmall
                                                    .copyWith(
                                                  color: AppColors.primary,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Divider(
                                      height: 1,
                                      color: AppColors.outlineVariant
                                          .withOpacity(0.4),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Scrollable Facility List Area
                          Expanded(
                            child: CustomScrollView(
                              controller: scrollController,
                              physics: const ClampingScrollPhysics(),
                              slivers: [
                                // Permission Helper Banner (if needed)
                                if (state.locationStatus !=
                                        LocationPermissionStatus.granted &&
                                    state.locationStatus !=
                                        LocationPermissionStatus.unknown)
                                  SliverToBoxAdapter(
                                    child: _buildPermissionBanner(
                                        context, state, notifier),
                                  ),

                                // Facility List Cards, Loading Skeleton, or Empty State
                                if (state.isLoading)
                                  SliverToBoxAdapter(
                                    child: _buildLoadingSkeleton(),
                                  )
                                else if (state.places.isEmpty)
                                  SliverToBoxAdapter(
                                    child: _buildEmptyState(
                                        context, notifier, state),
                                  )
                                else
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                        16, 6, 16, 24),
                                    sliver: SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, index) {
                                          final place = state.places[index];
                                          return HealthcareCard(
                                            place: place,
                                            onTap: () => _onPlaceTap(place),
                                            onCall: () => _onCall(place),
                                            onDirections: () =>
                                                _onDirections(place),
                                            onBookAppointment: () =>
                                                _onBookAppointment(place),
                                          );
                                        },
                                        childCount: state.places.length,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                // 4. Sleek OpenStreetMap Data Loading Screen / Overlay
                if (state.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withValues(alpha: 0.55),
                      child: Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 28),
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 20,
                                spreadRadius: 2,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: SizedBox(
                                    width: 36,
                                    height: 36,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3.5,
                                      valueColor:
                                          AlwaysStoppedAnimation<Color>(
                                        AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                loc.translate('fetchingOsmData'),
                                style: AppTextStyles.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.onSurface,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loc.translate('queryingOsmSubtitle'),
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.onSurfaceVariant,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 14),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusFull,
                                  ),
                                  border: Border.all(
                                    color: AppColors.outlineVariant
                                        .withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: AppColors.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        state.userLocation?.placename ??
                                            loc.translate(
                                                'detectedLocation'),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionBanner(
    BuildContext context,
    HealthcareFinderState state,
    HealthcareFinderNotifier notifier,
  ) {
    final loc = AppLocalizations.of(context);
    final isGpsDisabled =
        state.locationStatus == LocationPermissionStatus.serviceDisabled;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer.withOpacity(0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_off_rounded,
            color: AppColors.warning,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGpsDisabled
                      ? loc.translate('turnOnGps')
                      : loc.translate('locationPermissionRequired'),
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  isGpsDisabled
                      ? loc.translate('gpsDisabledHint')
                      : loc.translate('locationPermissionHint'),
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () => notifier.requestPermission(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: const Size(60, 36),
            ),
            child: Text(
              loc.translate('enable'),
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          height: 120,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          child: const Center(
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    HealthcareFinderNotifier notifier,
    HealthcareFinderState state,
  ) {
    final loc = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.location_searching_rounded,
              size: 44,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 10),
            Text(
              loc.translate('noHealthcareFound'),
              style: AppTextStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              loc.translate('noHealthcareHint'),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.icon(
                  onPressed: () =>
                      _openAreaSelectorModal(context, notifier, state),
                  icon: const Icon(Icons.location_city_rounded, size: 16),
                  label: Text(loc.translate('changeArea')),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => notifier.initialize(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(loc.translate('retry')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openAreaSelectorModal(
    BuildContext context,
    HealthcareFinderNotifier notifier,
    HealthcareFinderState state,
  ) {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusXl),
        ),
      ),
      builder: (modalContext) {
        return _AreaSelectorBottomSheet(
          loc: loc,
          notifier: notifier,
        );
      },
    );
  }
}

class _AreaPreset {
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const _AreaPreset({
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}

const List<_AreaPreset> _kPopularAreas = [
  _AreaPreset(
    name: 'Satara District',
    region: 'Maharashtra',
    latitude: 17.6805,
    longitude: 74.0183,
  ),
  _AreaPreset(
    name: 'Wai',
    region: 'Satara, Maharashtra',
    latitude: 17.9490,
    longitude: 73.8927,
  ),
  _AreaPreset(
    name: 'Koregaon',
    region: 'Satara, Maharashtra',
    latitude: 17.7018,
    longitude: 74.1681,
  ),
  _AreaPreset(
    name: 'Karad',
    region: 'Satara, Maharashtra',
    latitude: 17.2885,
    longitude: 74.1844,
  ),
  _AreaPreset(
    name: 'Medha',
    region: 'Satara, Maharashtra',
    latitude: 17.7766,
    longitude: 73.8344,
  ),
  _AreaPreset(
    name: 'Phaltan',
    region: 'Satara, Maharashtra',
    latitude: 17.9866,
    longitude: 74.4333,
  ),
  _AreaPreset(
    name: 'Mahabaleshwar',
    region: 'Satara, Maharashtra',
    latitude: 17.9237,
    longitude: 73.6586,
  ),
  _AreaPreset(
    name: 'Shirwal',
    region: 'Satara, Maharashtra',
    latitude: 18.1340,
    longitude: 73.9870,
  ),
  _AreaPreset(
    name: 'Pune',
    region: 'Maharashtra',
    latitude: 18.5204,
    longitude: 73.8567,
  ),
  _AreaPreset(
    name: 'Mumbai',
    region: 'Maharashtra',
    latitude: 19.0760,
    longitude: 72.8777,
  ),
  _AreaPreset(
    name: 'Delhi NCR',
    region: 'Delhi',
    latitude: 28.6139,
    longitude: 77.2090,
  ),
  _AreaPreset(
    name: 'Bengaluru',
    region: 'Karnataka',
    latitude: 12.9716,
    longitude: 77.5946,
  ),
  _AreaPreset(
    name: 'Kolkata',
    region: 'West Bengal',
    latitude: 22.5726,
    longitude: 88.3639,
  ),
];

class _AreaSelectorBottomSheet extends StatefulWidget {
  final AppLocalizations loc;
  final HealthcareFinderNotifier notifier;

  const _AreaSelectorBottomSheet({
    required this.loc,
    required this.notifier,
  });

  @override
  State<_AreaSelectorBottomSheet> createState() =>
      _AreaSelectorBottomSheetState();
}

class _AreaSelectorBottomSheetState extends State<_AreaSelectorBottomSheet> {
  final TextEditingController _areaSearchController = TextEditingController();
  List<_AreaPreset> _filteredAreas = _kPopularAreas;

  @override
  void initState() {
    super.initState();
    _areaSearchController.addListener(_onFilterChanged);
  }

  @override
  void dispose() {
    _areaSearchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    final query = _areaSearchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredAreas = _kPopularAreas;
      } else {
        _filteredAreas = _kPopularAreas
            .where((area) =>
                area.name.toLowerCase().contains(query) ||
                area.region.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _selectArea(_AreaPreset area) {
    widget.notifier.searchAtCoordinates(
      area.latitude,
      area.longitude,
      areaName: '${area.name}, ${area.region}',
    );
    Navigator.of(context).pop();
  }

  void _useGps() {
    widget.notifier.requestLocationAndSearch();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.72,
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Modal Handle
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.loc.translate('selectArea'),
                  style: AppTextStyles.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Live GPS Quick Action Button
            InkWell(
              onTap: _useGps,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.my_location_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.loc.translate('useLiveGps'),
                        style: AppTextStyles.labelLarge.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Search Area Input
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
                border: Border.all(color: AppColors.outlineVariant),
              ),
              child: TextField(
                controller: _areaSearchController,
                decoration: InputDecoration(
                  hintText: widget.loc.translate('searchAreaHint'),
                  hintStyle: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 13,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                  suffixIcon: _areaSearchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16),
                          onPressed: () => _areaSearchController.clear(),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 12),

            Text(
              widget.loc.translate('popularAreas'),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Areas List
            Flexible(
              child: _filteredAreas.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          widget.loc.translate('noFacilitiesFound'),
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _filteredAreas.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1, indent: 40),
                      itemBuilder: (context, index) {
                        final area = _filteredAreas[index];
                        return ListTile(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 4),
                          dense: true,
                          leading: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primaryContainer.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.location_city_rounded,
                              size: 16,
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(
                            area.name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            area.region,
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 12,
                            color: AppColors.outlineVariant,
                          ),
                          onTap: () => _selectArea(area),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
