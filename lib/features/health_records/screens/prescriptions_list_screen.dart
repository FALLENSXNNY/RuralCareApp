import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/prescription.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/section_card.dart';

class PrescriptionsListScreen extends ConsumerStatefulWidget {
  const PrescriptionsListScreen({super.key});

  @override
  ConsumerState<PrescriptionsListScreen> createState() =>
      _PrescriptionsListScreenState();
}

class _PrescriptionsListScreenState
    extends ConsumerState<PrescriptionsListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rxAsync = ref.watch(prescriptionsProvider);

    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Prescriptions'),
        backgroundColor: AppColors.surface,
      ),
      body: Column(
        children: [
          // Search bar
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by doctor or medicine...',
                prefixIcon: const Icon(Icons.search, color: AppColors.textMuted),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                filled: true,
                fillColor: AppColors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Prescriptions list
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(prescriptionsProvider);
                await ref.read(prescriptionsProvider.future);
              },
              child: rxAsync.when(
                data: (prescriptions) {
                  final filtered = prescriptions.where((rx) {
                    if (_searchQuery.isEmpty) return true;
                    final matchDoctor = rx.doctorName.toLowerCase().contains(_searchQuery);
                    final matchMeds = rx.medicines.any((m) => m.toLowerCase().contains(_searchQuery));
                    final matchNotes = rx.notes.toLowerCase().contains(_searchQuery);
                    return matchDoctor || matchMeds || matchNotes;
                  }).toList();

                  if (filtered.isEmpty) {
                    return ListView(
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEDE7F6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.medication_outlined,
                                    size: 32, color: Color(0xFF6750A4)),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'No Prescriptions Found'
                                    : 'No matching prescriptions',
                                style: AppTextStyles.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _searchQuery.isEmpty
                                    ? 'Prescriptions from doctors will appear here'
                                    : 'Try searching with another doctor name or medicine',
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
                      final rx = filtered[index];
                      return _PrescriptionCard(rx: rx);
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
                        Text('Failed to load prescriptions',
                            style: AppTextStyles.titleMedium),
                        const SizedBox(height: 4),
                        Text('$err',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted),
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => ref.invalidate(prescriptionsProvider),
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

class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.rx});
  final Prescription rx;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      onTap: () => context.push('/records/prescription/${rx.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.medication_outlined,
                    color: Color(0xFF6750A4), size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(rx.doctorName, style: AppTextStyles.titleSmall),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            size: 13, color: AppColors.textMuted),
                        const SizedBox(width: 4),
                        Text(rx.date,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.textMuted)),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${rx.medicines.length} Meds',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
            ],
          ),
          if (rx.medicines.isNotEmpty) ...[
            const Divider(height: 20),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: rx.medicines.take(3).map((m) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.border, width: 0.5),
                  ),
                  child: Text(
                    m,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
            if (rx.medicines.length > 3)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '+${rx.medicines.length - 3} more medicines',
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.primary),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
