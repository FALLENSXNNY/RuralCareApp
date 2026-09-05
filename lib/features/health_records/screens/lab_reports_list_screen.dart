import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/lab_report.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';

class LabReportsListScreen extends ConsumerStatefulWidget {
  const LabReportsListScreen({super.key});

  @override
  ConsumerState<LabReportsListScreen> createState() =>
      _LabReportsListScreenState();
}

class _LabReportsListScreenState extends ConsumerState<LabReportsListScreen> {
  String _selectedFilter = 'ALL';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = const ['ALL', 'NORMAL', 'ABNORMAL'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final labAsync = ref.watch(labReportsProvider);
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: Text(l10n.labReports),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search & Filter header
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (val) =>
                      setState(() => _searchQuery = val.trim().toLowerCase()),
                  decoration: InputDecoration(
                    hintText: l10n.searchLabReportsHint,
                    prefixIcon:
                        const Icon(Icons.search, color: AppColors.textMuted),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    filled: true,
                    fillColor: AppColors.surfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: _filterOptions.map((f) {
                    final isSelected = _selectedFilter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: isSelected,
                        onSelected: (_) => setState(() => _selectedFilter = f),
                        selectedColor: f == 'Abnormal'
                            ? AppColors.emergencyContainer
                            : AppColors.primaryContainer,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? (f == 'Abnormal'
                                  ? AppColors.emergency
                                  : AppColors.primary)
                              : AppColors.textMuted,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),

          // Reports list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(labReportsProvider);
                await ref.read(labReportsProvider.future);
              },
              child: labAsync.when(
                data: (reports) {
                  final filtered = reports.where((r) {
                    // Filter chip
                    if (_selectedFilter != 'All') {
                      if (_selectedFilter == 'Abnormal' && !r.isAbnormal) {
                        return false;
                      }
                      if (_selectedFilter == 'Normal' && r.isAbnormal) {
                        return false;
                      }
                    }
                    // Search
                    if (_searchQuery.isNotEmpty) {
                      final matchTest =
                          r.testName.toLowerCase().contains(_searchQuery);
                      final matchFac =
                          r.facility.toLowerCase().contains(_searchQuery);
                      final matchRes =
                          r.result.toLowerCase().contains(_searchQuery);
                      return matchTest || matchFac || matchRes;
                    }
                    return true;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(
                            height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE1F5FE),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.science_outlined,
                                    size: 32, color: Color(0xFF0277BD)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedFilter == 'All'
                                    ? 'No Diagnostic Reports'
                                    : 'No matching lab reports',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedFilter == 'All'
                                    ? 'Your lab tests and diagnostic results will appear here'
                                    : 'Try changing the filter or search query',
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: AppColors.textMuted),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(AppConstants.screenPadding),
                    itemCount: filtered.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final report = filtered[index];
                      return _LabReportCard(report: report);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 44, color: AppColors.emergency),
                        const SizedBox(height: 12),
                        Text('Failed to load lab reports',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('$err',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(labReportsProvider),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LabReportCard extends StatelessWidget {
  const _LabReportCard({required this.report});
  final LabReport report;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: () => context.push('/records/lab/${report.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE1F5FE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.science_outlined,
                    color: Color(0xFF0277BD), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(report.testName, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(report.facility,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.textMuted)),
                  ],
                ),
              ),
              StatusBadge(
                status: report.isAbnormal
                    ? StatusType.emergency
                    : StatusType.active,
                customLabel: report.status,
              ),
            ],
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 13, color: AppColors.textMuted),
                  const SizedBox(width: 4),
                  Text(report.date,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
              Flexible(
                child: Text(
                  report.result,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: report.isAbnormal
                        ? AppColors.emergency
                        : AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
