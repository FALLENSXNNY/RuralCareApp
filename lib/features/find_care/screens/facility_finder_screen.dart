import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/mock/mock_patient_data.dart';
import '../../../core/models/facility.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class FacilityFinderScreen extends ConsumerStatefulWidget {
  const FacilityFinderScreen({super.key});

  @override
  ConsumerState<FacilityFinderScreen> createState() =>
      _FacilityFinderScreenState();
}

class _FacilityFinderScreenState extends ConsumerState<FacilityFinderScreen> {
  String _filter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final List<String> _filters = ['All', 'PHC', 'CHC', 'Hospital', 'Clinic'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<HealthcareFacility> _filterFacilities(List<HealthcareFacility> list) {
    var result = list;

    // Filter by type
    if (_filter != 'All') {
      result = result.where((f) {
        if (_filter == 'Hospital') {
          return f.type.toLowerCase().contains('hospital');
        }
        return f.type.toLowerCase().contains(_filter.toLowerCase());
      }).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      result = result.where((f) {
        return f.name.toLowerCase().contains(q) ||
            f.address.toLowerCase().contains(q) ||
            f.type.toLowerCase().contains(q) ||
            f.services.any((s) => s.toLowerCase().contains(q));
      }).toList();
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsync = ref.watch(facilitiesProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Find Healthcare'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.invalidate(facilitiesProvider),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyMedium,
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                hintText: 'Search facilities, locations, or services...',
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

          // Find doctor shortcut
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SectionCard(
              onTap: () => context.go(AppRoutes.findDoctor),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.person_search_outlined,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Find a Doctor', style: AppTextStyles.titleSmall),
                        Text(
                          'Search by speciality, hospital, or name',
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

          // Filter chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: _filters.map((f) {
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(f),
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

          const SizedBox(height: 12),

          // Facility list view
          Expanded(
            child: facilitiesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (err, stack) {
                final fallbackList = _filterFacilities(MockPatientData.facilities);
                return _buildFacilityListView(fallbackList);
              },
              data: (facilities) {
                final list = _filterFacilities(
                  facilities.isNotEmpty ? facilities : MockPatientData.facilities,
                );
                return _buildFacilityListView(list);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacilityListView(List<HealthcareFacility> list) {
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
                'No healthcare facilities found',
                style: AppTextStyles.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Try adjusting your search query or category filters.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.textMuted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => ref.invalidate(facilitiesProvider),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.screenPadding,
          vertical: 4,
        ),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) => _FacilityCard(facility: list[i]),
      ),
    );
  }
}

class _FacilityCard extends StatelessWidget {
  const _FacilityCard({required this.facility});
  final HealthcareFacility facility;

  Future<void> _call() async {
    if (facility.phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: facility.phone.replaceAll('-', ''));
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openDirections() async {
    final query = Uri.encodeComponent('${facility.name}, ${facility.address}');
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
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
              // Open/closed badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: facility.isOpen
                      ? AppColors.secondaryContainer
                      : AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
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
                          ? AppColors.success
                          : AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      facility.isOpen ? 'Open' : 'Closed',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: facility.isOpen
                            ? AppColors.success
                            : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),

          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  facility.address,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
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

          if (facility.services.isNotEmpty) ...[
            const SizedBox(height: 12),
            // Services chips
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

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.phone, size: 16),
                  label: Text(
                    facility.phone.isNotEmpty
                        ? 'Call ${facility.phone}'
                        : 'Call Facility',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 42),
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
                tooltip: 'Get Directions',
                style: IconButton.styleFrom(
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
