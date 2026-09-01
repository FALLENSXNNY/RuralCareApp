import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/health_record.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class HealthTimelineScreen extends ConsumerStatefulWidget {
  const HealthTimelineScreen({super.key});

  @override
  ConsumerState<HealthTimelineScreen> createState() =>
      _HealthTimelineScreenState();
}

class _HealthTimelineScreenState extends ConsumerState<HealthTimelineScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = [
    'All',
    'Prescription',
    'Lab Report',
    'Consultation',
    'Referral',
  ];

  @override
  Widget build(BuildContext context) {
    final timelineAsync = ref.watch(healthTimelineProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Health Timeline'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Filter chips
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _filters.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => setState(() => _selectedFilter = filter),
                      selectedColor: AppColors.primaryContainer,
                      labelStyle: AppTextStyles.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textMuted,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Timeline list
          Expanded(
            child: timelineAsync.when(
              data: (records) {
                final filtered = _selectedFilter == 'All'
                    ? records
                    : records
                        .where((r) =>
                            r.type.toLowerCase() == _selectedFilter.toLowerCase())
                        .toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.timeline_outlined,
                            size: 48, color: AppColors.textMuted),
                        const SizedBox(height: 12),
                        Text(
                          'No timeline events found',
                          style: AppTextStyles.titleMedium
                              .copyWith(color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(AppConstants.screenPadding),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    final isLast = i == filtered.length - 1;
                    final config = _getEventConfig(item.type);

                    return IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Timeline line + dot
                          SizedBox(
                            width: 40,
                            child: Column(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: config.color.withValues(alpha: 0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(config.icon,
                                      color: config.color, size: 18),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 4),
                                      color: AppColors.border,
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 12),

                          // Event card
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 16),
                              child: InkWell(
                                onTap: () => _handleItemTap(context, item),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppColors.surface,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                        color: AppColors.border, width: 0.5),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: config.color
                                                  .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(item.type,
                                                style: AppTextStyles.labelSmall
                                                    .copyWith(
                                                        color: config.color)),
                                          ),
                                          Text(item.date,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                      color:
                                                          AppColors.textMuted)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(item.title,
                                          style: AppTextStyles.titleSmall),
                                      const SizedBox(height: 2),
                                      Text(item.subtitle,
                                          style: AppTextStyles.bodySmall
                                              .copyWith(
                                                  color:
                                                      AppColors.textMuted)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 40, color: AppColors.emergency),
                    const SizedBox(height: 12),
                    Text('Failed to load timeline: $err',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(healthTimelineProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleItemTap(BuildContext context, HealthRecord record) {
    final relatedId = record.relatedId ?? record.id;
    final type = record.type.toLowerCase();

    if (type.contains('prescription')) {
      context.push('/records/prescription/$relatedId');
    } else if (type.contains('lab') || type.contains('diagnostic')) {
      context.push('/records/lab/$relatedId');
    } else if (type.contains('referral')) {
      context.push('/records/referral/$relatedId');
    } else if (type.contains('consultation') || type.contains('visit')) {
      context.push('/records/consultation/$relatedId');
    }
  }

  _EventConfig _getEventConfig(String type) {
    final t = type.toLowerCase();
    if (t.contains('prescription')) {
      return const _EventConfig(
          icon: Icons.medication_outlined, color: Color(0xFF6750A4));
    } else if (t.contains('lab') || t.contains('diagnostic')) {
      return const _EventConfig(
          icon: Icons.science_outlined, color: Color(0xFF0277BD));
    } else if (t.contains('referral')) {
      return const _EventConfig(
          icon: Icons.transfer_within_a_station, color: AppColors.secondary);
    } else {
      return const _EventConfig(
          icon: Icons.event_note_outlined, color: Color(0xFF00838F));
    }
  }
}

class _EventConfig {
  final IconData icon;
  final Color color;

  const _EventConfig({required this.icon, required this.color});
}

