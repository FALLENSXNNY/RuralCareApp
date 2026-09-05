import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/facility.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/location_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class FacilityFinderScreen extends ConsumerStatefulWidget {
  final String? initialCategory;
  final bool isEmergencyMode;

  const FacilityFinderScreen({
    super.key,
    this.initialCategory,
    this.isEmergencyMode = false,
  });

  @override
  ConsumerState<FacilityFinderScreen> createState() =>
      _FacilityFinderScreenState();
}

class _FacilityFinderScreenState extends ConsumerState<FacilityFinderScreen> {
  late String _filter;
  late bool _emergencyActive;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filters = [
    'All',
    'Hospitals',
    'Clinics',
    'Maternal Care',
    '24x7 Emergency',
  ];

  @override
  void initState() {
    super.initState();
    _filter = widget.initialCategory ?? 'All';
    _emergencyActive = widget.isEmergencyMode;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getFilterLabel(String filter, AppLocalizations l10n) {
    switch (filter) {
      case 'All':
        return l10n.filterAll;
      case 'Hospitals':
        return l10n.hospitals;
      case 'Clinics':
        return l10n.clinics;
      case 'Maternal Care':
        return l10n.maternalCare;
      case '24x7 Emergency':
        return l10n.emergency24x7;
      default:
        return filter;
    }
  }

  Future<void> _refreshLocation() async {
    ref.invalidate(userLocationProvider);
    ref.invalidate(locationPermissionStatusProvider);
  }

  Future<void> _callAmbulance() async {
    final uri = Uri(scheme: 'tel', path: AppConstants.emergencyNumber);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locationAsync = ref.watch(userLocationProvider);
    final permissionAsync = ref.watch(locationPermissionStatusProvider);

    final searchParams = FacilitySearchParams(
      category: _filter,
      searchQuery: _searchQuery,
      isEmergencyMode: _emergencyActive,
    );

    final facilitiesAsync = ref.watch(gpsHealthcareFacilitiesProvider(searchParams));

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(l10n.findHealthcare),
        backgroundColor: AppColors.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refreshLocation,
            onPressed: () {
              _refreshLocation();
              ref.invalidate(gpsHealthcareFacilitiesProvider(searchParams));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Location Status Bar
          _buildLocationStatusBar(context, locationAsync, permissionAsync, l10n),

          // Permission Warning Card if restricted
          _buildPermissionBanner(context, permissionAsync, l10n),

          // Emergency Triage Alert Banner (if opened in emergency mode)
          if (_emergencyActive)
            _buildEmergencyTriageBanner(context, l10n),

          // Search input bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyMedium,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: l10n.searchFacilitiesHint,
                prefixIcon: const Icon(
                  Icons.search,
                  color: AppColors.textMuted,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ),

          // Find doctor shortcut banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: SectionCard(
              onTap: () => context.go(AppRoutes.findDoctor),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.findADoctor, style: AppTextStyles.titleSmall),
                        Text(
                          l10n.findDoctorSubtitle,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          // Filter category chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
            child: Row(
              children: _filters.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(_getFilterLabel(f, l10n)),
                    selected: selected,
                    onSelected: (_) => setState(() => _filter = f),
                    selectedColor: AppColors.primaryContainer,
                    labelStyle: AppTextStyles.labelMedium.copyWith(
                      color: selected ? AppColors.primary : AppColors.textMuted,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(
                      color: selected ? AppColors.primary : AppColors.border,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 6),

          // Facility list view
          Expanded(
            child: facilitiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 40, color: AppColors.error),
                      const SizedBox(height: 12),
                      Text(l10n.noFacilitiesFound, style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => ref.invalidate(
                          gpsHealthcareFacilitiesProvider(searchParams),
                        ),
                        child: Text(l10n.retry),
                      ),
                    ],
                  ),
                ),
              ),
              data: (facilities) => _buildFacilityListView(facilities, l10n),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationStatusBar(
    BuildContext context,
    AsyncValue<UserLocation?> locationAsync,
    AsyncValue<LocationPermissionStatus> permissionAsync,
    AppLocalizations l10n,
  ) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(
            Icons.my_location,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: locationAsync.when(
              data: (loc) {
                final name = loc?.placename ?? 'Satara District, Maharashtra';
                return Text(
                  l10n.nearLocation(name),
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  overflow: TextOverflow.ellipsis,
                );
              },
              loading: () => Text(
                'Detecting GPS location...',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
              error: (_, _) => Text(
                l10n.nearLocation('Satara Rural District'),
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'GPS Active',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.secondary,
                    fontSize: 10,
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
    AsyncValue<LocationPermissionStatus> permissionAsync,
    AppLocalizations l10n,
  ) {
    final status = permissionAsync.valueOrNull;
    if (status == null || status == LocationPermissionStatus.granted) {
      return const SizedBox.shrink();
    }

    final isPermanentlyDenied =
        status == LocationPermissionStatus.permanentlyDenied;
    final isGpsDisabled = status == LocationPermissionStatus.serviceDisabled;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_off_outlined, color: AppColors.warning, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isGpsDisabled
                      ? l10n.gpsDisabled
                      : l10n.permissionRequired,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  l10n.permissionExpl,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () async {
              final locService = ref.read(locationServiceProvider);
              if (isPermanentlyDenied) {
                await locService.openAppSettings();
              } else if (isGpsDisabled) {
                await locService.openLocationSettings();
              } else {
                await locService.requestPermission();
              }
              _refreshLocation();
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: Text(
              isPermanentlyDenied ? l10n.openSettings : l10n.grantPermission,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyTriageBanner(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.emergency,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.emergencyTriageBanner,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _callAmbulance,
                  icon: const Icon(Icons.phone_in_talk, size: 18, color: AppColors.emergency),
                  label: Text(
                    l10n.call108Ambulance,
                    style: AppTextStyles.labelMedium.copyWith(
                      color: AppColors.emergency,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(0, 44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.white70, size: 20),
                tooltip: l10n.close,
                onPressed: () => setState(() => _emergencyActive = false),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityListView(
    List<HealthcareFacility> list,
    AppLocalizations l10n,
  ) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.local_hospital_outlined,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noFacilitiesFound,
                style: AppTextStyles.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                l10n.adjustFiltersHint,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _refreshLocation();
        ref.invalidate(gpsHealthcareFacilitiesProvider);
      },
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPadding,
          vertical: 4,
        ),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) =>
            _FacilityCard(facility: list[i], l10n: l10n),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.facility, required this.l10n});
  final HealthcareFacility facility;
  final AppLocalizations l10n;

  Future<void> _call() async {
    if (facility.phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: facility.phone.replaceAll('-', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    Uri uri;
    if (facility.latitude != null && facility.longitude != null) {
      uri = Uri.parse(
        'https://www.google.com/maps/dir/?api=1&destination=${facility.latitude},${facility.longitude}',
      );
    } else {
      final query = Uri.encodeComponent('${facility.name}, ${facility.address}');
      uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    }

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(facility.name, style: AppTextStyles.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      facility.type,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Open/Closed badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: facility.isOpen
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      facility.isOpen
                          ? Icons.check_circle
                          : Icons.cancel_outlined,
                      size: 12,
                      color: facility.isOpen
                          ? AppColors.secondary
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      facility.isOpen ? l10n.statusOpen : l10n.statusClosed,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: facility.isOpen
                            ? AppColors.secondary
                            : AppColors.textMuted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Location and Distance
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 15,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  facility.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              if (facility.distance.isNotEmpty)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    facility.distance,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.access_time,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                facility.hours,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),

          // Capability Badges (24x7 Emergency / Maternal Care)
          if (facility.isEmergency24x7 || facility.hasMaternalCare) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                if (facility.isEmergency24x7)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.local_hospital,
                          size: 12,
                          color: AppColors.emergency,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.emergency24x7,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.emergency,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (facility.hasMaternalCare)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.pregnant_woman,
                          size: 12,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          l10n.maternalCare,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],

          if (facility.services.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: facility.services.take(4).map((s) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    s,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          const SizedBox(height: 12),

          // Action Buttons: Call & Directions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(
                    facility.phone.isNotEmpty
                        ? l10n.callPhone(facility.phone)
                        : l10n.callFacility,
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 48),
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: AppTextStyles.labelMedium,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filledTonal(
                icon: const Icon(Icons.directions, size: 20),
                onPressed: _openDirections,
                tooltip: l10n.getDirections,
                style: IconButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
