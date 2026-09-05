import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/models/pregnancy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utilities/pregnancy_calculator.dart';
import '../../../core/widgets/ruralcare_button.dart';

class PregnancySetupModal extends ConsumerStatefulWidget {
  const PregnancySetupModal({super.key, required this.profile});

  final PregnancyProfile profile;

  static Future<void> show(BuildContext context, PregnancyProfile profile) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PregnancySetupModal(profile: profile),
    );
  }

  @override
  ConsumerState<PregnancySetupModal> createState() => _PregnancySetupModalState();
}

class _PregnancySetupModalState extends ConsumerState<PregnancySetupModal> {
  DateTime? _selectedEdd;
  DateTime? _selectedLmp;
  bool _useLmp = false;

  @override
  void initState() {
    super.initState();
    _selectedEdd = widget.profile.estimatedDueDate ?? DateTime.now().add(const Duration(days: 112));
    _selectedLmp = widget.profile.lastMenstrualPeriod ??
        PregnancyCalculator.calculateLmpFromEdd(_selectedEdd!);
  }

  Future<void> _pickEddDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEdd ?? now.add(const Duration(days: 112)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 300)),
      helpText: context.l10n.selectDueDate,
    );

    if (picked != null) {
      setState(() {
        _selectedEdd = picked;
        _selectedLmp = PregnancyCalculator.calculateLmpFromEdd(picked);
      });
    }
  }

  Future<void> _pickLmpDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedLmp ?? now.subtract(const Duration(days: 90)),
      firstDate: now.subtract(const Duration(days: 280)),
      lastDate: now,
      helpText: context.l10n.selectLmpDate,
    );

    if (picked != null) {
      setState(() {
        _selectedLmp = picked;
        _selectedEdd = PregnancyCalculator.calculateEddFromLmp(picked);
      });
    }
  }

  Future<void> _saveDates() async {
    final l10n = context.l10n;
    if (_selectedEdd == null) return;

    await ref
        .read(pregnancyProfileControllerProvider.notifier)
        .updateDates(edd: _selectedEdd, lmp: _selectedLmp);

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pregnancyProfileUpdated),
          backgroundColor: AppColors.secondary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final calculatedWeek = PregnancyCalculator.calculateGestationalWeek(
      edd: _selectedEdd,
      lmp: _selectedLmp,
    );
    final calculatedTrimester = PregnancyCalculator.calculateTrimester(calculatedWeek);
    final daysRemaining = PregnancyCalculator.calculateDaysRemaining(_selectedEdd);

    final trimesterName = switch (calculatedTrimester) {
      PregnancyTrimester.first => l10n.trimester1,
      PregnancyTrimester.second => l10n.trimester2,
      PregnancyTrimester.third => l10n.trimester3,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(l10n.enterEddOrLmp, style: AppTextStyles.titleLarge),
          const SizedBox(height: 16),

          // Method toggle
          Row(
            children: [
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      l10n.dueDate,
                      style: AppTextStyles.labelMedium.copyWith(
                        color: !_useLmp ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: !_useLmp ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: !_useLmp,
                  onSelected: (val) => setState(() => _useLmp = !val),
                  selectedColor: AppColors.primaryContainer,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ChoiceChip(
                  label: Center(
                    child: Text(
                      'Last Period (LMP)',
                      style: AppTextStyles.labelMedium.copyWith(
                        color: _useLmp ? AppColors.primary : AppColors.textPrimary,
                        fontWeight: _useLmp ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                  selected: _useLmp,
                  onSelected: (val) => setState(() => _useLmp = val),
                  selectedColor: AppColors.primaryContainer,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Date Selector Button
          InkWell(
            onTap: () => _useLmp ? _pickLmpDate(context) : _pickEddDate(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _useLmp ? l10n.selectLmpDate : l10n.selectDueDate,
                          style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _useLmp
                              ? (_selectedLmp != null
                                  ? DateFormat('dd MMMM yyyy').format(_selectedLmp!)
                                  : 'Not set')
                              : (_selectedEdd != null
                                  ? DateFormat('dd MMMM yyyy').format(_selectedEdd!)
                                  : 'Not set'),
                          style: AppTextStyles.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit, size: 18, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Calculated preview card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l10n.currentWeek(calculatedWeek)} · $trimesterName',
                        style: AppTextStyles.titleSmall.copyWith(color: AppColors.primary),
                      ),
                      Text(
                        l10n.daysRemaining(daysRemaining),
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          RuralCareButton(
            label: l10n.saveDueDate,
            onPressed: _saveDates,
            icon: Icons.check,
          ),
        ],
      ),
    );
  }
}
