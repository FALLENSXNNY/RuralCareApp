import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/referral.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';
import '../../../core/widgets/status_badge.dart';

class ReferralsListScreen extends ConsumerStatefulWidget {
  const ReferralsListScreen({super.key});

  @override
  ConsumerState<ReferralsListScreen> createState() =>
      _ReferralsListScreenState();
}

class _ReferralsListScreenState extends ConsumerState<ReferralsListScreen> {
  String _selectedFilter = 'All';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  final List<String> _filterOptions = ['All', 'In-Progress', 'Completed'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final referralsAsync = ref.watch(referralsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Referrals Tracking'),
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
                    hintText: 'Search referred facility or speciality...',
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
                        selectedColor: AppColors.primaryContainer,
                        labelStyle: AppTextStyles.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
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

          // Referrals list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(referralsProvider);
                await ref.read(referralsProvider.future);
              },
              child: referralsAsync.when(
                data: (referrals) {
                  final filtered = referrals.where((refItem) {
                    final isCompleted = refItem.status.toLowerCase().contains('completed');
                    if (_selectedFilter == 'In-Progress' && isCompleted) return false;
                    if (_selectedFilter == 'Completed' && !isCompleted) return false;

                    if (_searchQuery.isNotEmpty) {
                      final matchFac =
                          refItem.referredTo.toLowerCase().contains(_searchQuery);
                      final matchSpec =
                          refItem.speciality.toLowerCase().contains(_searchQuery);
                      final matchReason =
                          refItem.reason.toLowerCase().contains(_searchQuery);
                      return matchFac || matchSpec || matchReason;
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
                                  color: AppColors.secondaryContainer,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                    Icons.transfer_within_a_station,
                                    size: 32,
                                    color: AppColors.secondary),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedFilter == 'All'
                                    ? 'No Referrals Found'
                                    : 'No matching referrals',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty &&
                                        _selectedFilter == 'All'
                                    ? 'Referrals to secondary or tertiary centers will appear here'
                                    : 'Try changing your search or filter',
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
                      final referral = filtered[index];
                      return _ReferralCard(referral: referral);
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
                        Text('Failed to load referrals',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('$err',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              ref.invalidate(referralsProvider),
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

class _ReferralCard extends StatelessWidget {
  const _ReferralCard({required this.referral});
  final Referral referral;

  @override
  Widget build(BuildContext context) {
    final statusLower = referral.status.toLowerCase();
    final isCompleted = statusLower.contains('completed');

    return SectionCard(
      onTap: () => context.push('/records/referral/${referral.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.transfer_within_a_station,
                    color: AppColors.secondary, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(referral.referredTo,
                        style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Text(referral.speciality,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              StatusBadge(
                status: isCompleted ? StatusType.active : StatusType.pending,
                customLabel: referral.status,
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
                  Text(referral.date,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textMuted)),
                ],
              ),
              Flexible(
                child: Text(
                  referral.reason,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
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
