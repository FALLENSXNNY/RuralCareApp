import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/child_care.dart';
import '../../../core/models/pregnancy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utilities/pregnancy_calculator.dart';
import '../../../core/widgets/language_selector_modal.dart';
import 'fetal_kick_counter_modal.dart';
import 'pregnancy_setup_screen.dart';

enum MotherChildSectionMode { pregnancy, childCare }

class PregnancyDashboardScreen extends ConsumerStatefulWidget {
  const PregnancyDashboardScreen({super.key});

  @override
  ConsumerState<PregnancyDashboardScreen> createState() =>
      _PregnancyDashboardScreenState();
}

class _PregnancyDashboardScreenState
    extends ConsumerState<PregnancyDashboardScreen>
    with TickerProviderStateMixin {
  MotherChildSectionMode _currentMode = MotherChildSectionMode.pregnancy;
  late TabController _trimesterTabController;
  ChildAgeBracket? _selectedVaccineFilter;
  bool _reminderSet = true;

  // Interactive daily checklist items with local persistence
  Map<String, bool> _dailyChecklist = {
    'ifa': true,
    'calcium': false,
    'water': true,
    'greens': false,
    'rest': true,
  };

  @override
  void initState() {
    super.initState();
    _trimesterTabController =
        TabController(length: 3, vsync: this, initialIndex: 1);
    _loadSavedChecklist();
  }

  void _loadSavedChecklist() {
    final storage = ref.read(localStorageProvider);
    final saved = storage.dailyChecklist;
    if (saved.isNotEmpty) {
      _dailyChecklist = {
        'ifa': saved['ifa'] ?? false,
        'calcium': saved['calcium'] ?? false,
        'water': saved['water'] ?? false,
        'greens': saved['greens'] ?? false,
        'rest': saved['rest'] ?? false,
      };
    }
  }

  void _updateChecklistItem(String key, bool value) {
    setState(() => _dailyChecklist[key] = value);
    ref.read(localStorageProvider).saveDailyChecklist(_dailyChecklist);
  }

  @override
  void dispose() {
    _trimesterTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final profileAsync = ref.watch(pregnancyProfileProvider);
    final visitsAsync = ref.watch(antenatalVisitsProvider);
    final vaccinesAsync = ref.watch(childVaccinesProvider);

    final langName = switch (locale.languageCode) {
      'hi' => 'हिन्दी',
      'bn' => 'বাংলা',
      _ => 'English',
    };

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
        title: Text(
          'Mother & Child Care',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: () => LanguageSelectorModal.show(context),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.language,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      langName,
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── TOP MODE SEGMENT SWITCHER ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8EEFC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _ModeSwitchButton(
                      label: 'Maternal Care',
                      icon: Icons.pregnant_woman_rounded,
                      isSelected:
                          _currentMode == MotherChildSectionMode.pregnancy,
                      onTap: () {
                        setState(() =>
                            _currentMode = MotherChildSectionMode.pregnancy);
                      },
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _ModeSwitchButton(
                      label: 'Child Care (0–5 Yrs)',
                      icon: Icons.child_care_rounded,
                      isSelected:
                          _currentMode == MotherChildSectionMode.childCare,
                      onTap: () {
                        setState(() =>
                            _currentMode = MotherChildSectionMode.childCare);
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── RENDER ACTIVE SECTION ────────────────────────────────────────
            if (_currentMode == MotherChildSectionMode.pregnancy)
              _buildMaternalSection(context, l10n, profileAsync, visitsAsync)
            else
              _buildChildCareSection(context, l10n, vaccinesAsync),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 1. MATERNAL CARE SECTION (PREGNANCY & POSTNATAL)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildMaternalSection(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<PregnancyProfile> profileAsync,
    AsyncValue<List<AntenatalVisit>> visitsAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Pregnancy Tracker Card
        profileAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Text('Error loading pregnancy data: $err'),
          ),
          data: (profile) {
            final week = profile.currentWeek;
            final trimester = PregnancyCalculator.calculateTrimester(week);
            final daysRemaining = PregnancyCalculator.calculateDaysRemaining(
                profile.estimatedDueDate);
            final progress =
                PregnancyCalculator.calculateProgressFraction(week);

            final trimesterLabel = switch (trimester) {
              PregnancyTrimester.first => l10n.trimester1,
              PregnancyTrimester.second => l10n.trimester2,
              PregnancyTrimester.third => l10n.trimester3,
            };

            final babySizeInfo = _getBabySizeComparison(week);

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E3FF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
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
                            Text(
                              l10n.currentWeek(week),
                              style: AppTextStyles.headlineMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              babySizeInfo.title,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: const Color(0xFF506079),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3F69C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          trimesterLabel,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: const Color(0xFF065F18),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Progress & Days Remaining
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Overall Progress (${(progress * 100).toInt()}%)',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        l10n.daysRemaining(daysRemaining),
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      backgroundColor: const Color(0xFFDEE8FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Baby Size Visual Pill
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF9E6),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFFE082)),
                    ),
                    child: Row(
                      children: [
                        Text(
                          babySizeInfo.emoji,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            babySizeInfo.description,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF5D4037),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Estimated Delivery Date Box
                  InkWell(
                    onTap: () => PregnancySetupModal.show(context, profile),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE7EEFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Estimated Delivery: ${profile.estimatedDueDate != null ? DateFormat('dd MMMM yyyy').format(profile.estimatedDueDate!) : "Not set"}',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: const Color(0xFF24334A),
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            size: 16,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 14),

        // 2. MATERNAL QUICK ACTIONS
        Row(
          children: [
            Expanded(
              child: _MaternalQuickActionCard(
                icon: Icons.favorite_rounded,
                iconColor: const Color(0xFFE91E63),
                title: 'Kick Counter',
                subtitle: 'Track 10 kicks',
                onTap: () => FetalKickCounterModal.show(context),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MaternalQuickActionCard(
                icon: Icons.emergency_rounded,
                iconColor: AppColors.emergencyRed,
                title: 'Danger Signs',
                subtitle: 'Call 108 / Help',
                onTap: () => context.push(AppRoutes.pregnancyWarningSigns),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _MaternalQuickActionCard(
                icon: Icons.local_hospital_rounded,
                iconColor: AppColors.primary,
                title: 'Maternal Care',
                subtitle: 'Hospitals & PHCs',
                onTap: () => context.push(
                  AppRoutes.facilityFinder,
                  extra: {'category': 'Maternal Care', 'emergency': false},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _MaternalQuickActionCard(
                icon: Icons.event_note_rounded,
                iconColor: const Color(0xFF2E7D32),
                title: 'All ANC Visits',
                subtitle: '4 WHO Visits',
                onTap: () => context.push(AppRoutes.antenatalSchedule),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 3. Next ANC Visit Card
        visitsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, _) => const SizedBox.shrink(),
          data: (visits) {
            final nextVisit = visits.firstWhere(
              (v) => !v.isCompleted,
              orElse: () => visits.first,
            );

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E3FF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.event,
                        color: AppColors.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n.nextAncVisit,
                          style: AppTextStyles.titleMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            context.push(AppRoutes.antenatalSchedule),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              l10n.viewAll,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE7EEFF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.schedule,
                                size: 16,
                                color: Color(0xFF506079),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nextVisit.title,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF24334A),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          nextVisit.scheduledDate != null
                              ? 'Scheduled: ${DateFormat('dd MMM yyyy').format(nextVisit.scheduledDate!)} (${nextVisit.weekRange})'
                              : nextVisit.weekRange,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: const Color(0xFF506079),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Color(0xFF506079),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                nextVisit.clinicName ??
                                    "Primary Health Centre",
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: const Color(0xFF506079),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed: () {
                      setState(() => _reminderSet = !_reminderSet);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _reminderSet
                                ? l10n.reminderSet
                                : 'Reminder removed',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      _reminderSet
                          ? Icons.notifications_active
                          : Icons.notifications_outlined,
                      size: 18,
                      color: _reminderSet
                          ? AppColors.secondary
                          : AppColors.primary,
                    ),
                    label: Text(
                      _reminderSet ? l10n.reminderSet : l10n.setReminder,
                      style: AppTextStyles.labelLarge.copyWith(
                        color: _reminderSet
                            ? AppColors.secondary
                            : AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 44),
                      side: BorderSide(
                        color: _reminderSet
                            ? AppColors.secondary
                            : AppColors.primary,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // 4. DYNAMIC TRIMESTER GUIDANCE TABS
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E3FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Color(0xFFF0F3FF),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: TabBar(
                  controller: _trimesterTabController,
                  onTap: (_) => setState(() {}),
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 4,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                  labelColor: AppColors.primary,
                  unselectedLabelColor: const Color(0xFF506079),
                  labelStyle: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  tabs: const [
                    Tab(text: '1st Trimester'),
                    Tab(text: '2nd Trimester'),
                    Tab(text: '3rd Trimester'),
                  ],
                ),
              ),

              // Trimester Dynamic Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: _buildTrimesterContent(_trimesterTabController.index),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 5. TODAY'S MATERNAL INTAKE CHECKLIST
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E3FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(
                        Icons.fact_check_outlined,
                        size: 20,
                        color: AppColors.secondary,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Today's Maternal Checklist",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFA3F69C),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_dailyChecklist.values.where((v) => v).length} of ${_dailyChecklist.length} done',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF065F18),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _ChecklistTile(
                title: 'Iron (IFA) Tablet taken with water/lemon (after meal)',
                isChecked: _dailyChecklist['ifa'] ?? false,
                onChanged: (val) => _updateChecklistItem('ifa', val ?? false),
              ),
              _ChecklistTile(
                title: 'Calcium Tablet taken (2 hours gap from Iron tablet)',
                isChecked: _dailyChecklist['calcium'] ?? false,
                onChanged: (val) =>
                    _updateChecklistItem('calcium', val ?? false),
              ),
              _ChecklistTile(
                title: '8–10 Glasses of clean boiled water',
                isChecked: _dailyChecklist['water'] ?? false,
                onChanged: (val) => _updateChecklistItem('water', val ?? false),
              ),
              _ChecklistTile(
                title: 'Green leafy vegetables, dal, or seasonal fruit',
                isChecked: _dailyChecklist['greens'] ?? false,
                onChanged: (val) =>
                    _updateChecklistItem('greens', val ?? false),
              ),
              _ChecklistTile(
                title: '1 Hour afternoon rest + sleep on left side',
                isChecked: _dailyChecklist['rest'] ?? false,
                onChanged: (val) => _updateChecklistItem('rest', val ?? false),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 6. GOVERNMENT SCHEMES & ENTITLEMENTS
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F8E9),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFC5E1A5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF33691E),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Government Maternity Entitlements',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF33691E),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const _GovSchemeBullet(
                title: 'Janani Suraksha Yojana (JSY):',
                desc:
                    '₹1,400 direct cash assistance for rural mothers delivering in government health centres.',
              ),
              const SizedBox(height: 6),
              const _GovSchemeBullet(
                title: 'Janani Shishu Suraksha Karyakram (JSSK):',
                desc:
                    '100% free delivery, C-section, medicines, food, blood & free 102/108 ambulance transport.',
              ),
              const SizedBox(height: 6),
              const _GovSchemeBullet(
                title: 'PMMVY Scheme:',
                desc:
                    '₹5,000 in direct bank transfers for first live birth across registration & immunizations.',
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 7. ASK PREGNANCY AI ASSISTANT CARD
        _buildAiAssistantCard(context, l10n),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 2. CHILD CARE SECTION (IMMUNIZATION & PEDIATRIC HEALTH)
  // ══════════════════════════════════════════════════════════════════════════
  Widget _buildChildCareSection(
    BuildContext context,
    AppLocalizations l10n,
    AsyncValue<List<ChildVaccine>> vaccinesAsync,
  ) {
    final milestones = ref.watch(childMilestonesProvider);
    final pncVisits = ref.watch(postnatalVisitsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Child Immunization Tracker Card
        vaccinesAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          ),
          error: (err, _) => Center(
            child: Text('Error loading vaccines: $err'),
          ),
          data: (allVaccines) {
            final completedCount =
                allVaccines.where((v) => v.isCompleted).length;
            final progressFraction = allVaccines.isNotEmpty
                ? completedCount / allVaccines.length
                : 0.0;

            final filteredVaccines = _selectedVaccineFilter == null
                ? allVaccines
                : allVaccines
                    .where((v) => v.ageBracket == _selectedVaccineFilter)
                    .toList();

            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD5E3FF)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(
                                color: Color(0xFFE7EEFF),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.vaccines_rounded,
                                color: AppColors.primary,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'National Immunization',
                                    style: AppTextStyles.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Universal Immunization (UIP)',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: const Color(0xFF506079),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA3F69C),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$completedCount / ${allVaccines.length}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: Color(0xFF065F18),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFDEE8FF),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF2E7D32),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Age Bracket Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: 'All Ages',
                          isSelected: _selectedVaccineFilter == null,
                          onTap: () =>
                              setState(() => _selectedVaccineFilter = null),
                        ),
                        _FilterChip(
                          label: 'At Birth',
                          isSelected: _selectedVaccineFilter ==
                              ChildAgeBracket.atBirth,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.atBirth),
                        ),
                        _FilterChip(
                          label: '6 Weeks',
                          isSelected:
                              _selectedVaccineFilter == ChildAgeBracket.weeks6,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.weeks6),
                        ),
                        _FilterChip(
                          label: '10 Weeks',
                          isSelected:
                              _selectedVaccineFilter == ChildAgeBracket.weeks10,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.weeks10),
                        ),
                        _FilterChip(
                          label: '14 Weeks',
                          isSelected:
                              _selectedVaccineFilter == ChildAgeBracket.weeks14,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.weeks14),
                        ),
                        _FilterChip(
                          label: '9–12 Months',
                          isSelected: _selectedVaccineFilter ==
                              ChildAgeBracket.months9to12,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.months9to12),
                        ),
                        _FilterChip(
                          label: '16–24 Months',
                          isSelected: _selectedVaccineFilter ==
                              ChildAgeBracket.months16to24,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.months16to24),
                        ),
                        _FilterChip(
                          label: '5–6 Years',
                          isSelected: _selectedVaccineFilter ==
                              ChildAgeBracket.years5to6,
                          onTap: () => setState(() => _selectedVaccineFilter =
                              ChildAgeBracket.years5to6),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Vaccine List
                  ...filteredVaccines.map((v) {
                    return _VaccineItemCard(
                      vaccine: v,
                      onToggle: (val) async {
                        await ref
                            .read(childCareRepositoryProvider)
                            .toggleVaccineStatus(v.id, val);
                        ref.invalidate(childVaccinesProvider);
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),

        const SizedBox(height: 16),

        // 2. ESSENTIAL NEWBORN & POSTNATAL CARE (PNC)
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E3FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.baby_changing_station,
                    color: AppColors.secondary,
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Essential Newborn Care Guidelines',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const _NewbornCareTile(
                icon: Icons.water_drop_outlined,
                title: 'Exclusive Breastfeeding (0–6 Months)',
                desc:
                    'Feed only breast milk for first 6 months. Do not give plain water, honey, ghutti, or cow milk.',
              ),
              const SizedBox(height: 8),
              const _NewbornCareTile(
                icon: Icons.volunteer_activism_rounded,
                title: 'Kangaroo Mother Care (KMC)',
                desc:
                    'Skin-to-skin contact on mother’s chest keeps low birth weight babies warm, reduces infections, and boosts growth.',
              ),
              const SizedBox(height: 8),
              const _NewbornCareTile(
                icon: Icons.sanitizer_rounded,
                title: 'Clean Cord Care',
                desc:
                    'Keep umbilical cord stump clean and dry. Never apply cow dung, ash, oil, or surma.',
              ),
              const SizedBox(height: 12),

              // PNC Visits Expansion
              Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  title: const Text(
                    'Postnatal Visits Schedule (6 Visits)',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.primary,
                    ),
                  ),
                  children: pncVisits.map((pnc) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F9FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFD5E3FF)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                pnc.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                pnc.timing,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF506079),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Baby Checks: ${pnc.newbornChecks.join(", ")}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: const Color(0xFF506079),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. CHILD DEVELOPMENT MILESTONES
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFD5E3FF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF2E7D32),
                    size: 22,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Developmental Milestones',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...milestones.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F9FF),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFD5E3FF)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              m.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: Color(0xFF24334A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE7EEFF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              m.ageRange,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ...m.keyMilestones.map((k) => Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 13,
                                  color: Color(0xFF2E7D32),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    k,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF506079),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF9E6),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '💡 Activity Tip: ${m.stimulationTip}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF5D4037),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. HOME CARE & ORS DIARRHEA / FEVER TRIAGE
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFFD54F)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Icon(
                    Icons.medication_liquid_rounded,
                    color: Color(0xFFF57F17),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Home Management: Diarrhea & Fever',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFFF57F17),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'How to make Home ORS (Oral Rehydration Solution):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF24334A),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '1 Litre clean boiled water + 6 level spoons Sugar + 1/2 level spoon Salt (or 1 packet WHO ORS). Give sips after every loose stool + Zinc 20mg for 14 days.',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF506079),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                '🚨 Rush to Hospital if child has:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: AppColors.emergencyRed,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '• Fast breathing (>50/min in 2–12 months)\n• Chest in-drawing or inability to breastfeed\n• High persistent fever or lethargy / unconsciousness',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF506079),
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 5. ASK CHILD CARE AI ASSISTANT CARD
        _buildAiAssistantCard(context, l10n),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER WIDGETS & TRIMESTER BUILDER
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildTrimesterContent(int index) {
    if (index == 0) {
      // 1st Trimester
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _NutrientCard(
            icon: Icons.medication_rounded,
            iconColor: AppColors.primary,
            title: 'Folic Acid (5mg)',
            badge: 'Essential',
            badgeColor: Color(0xFFE7EEFF),
            badgeTextColor: AppColors.primary,
            description:
                'Critical for baby\'s brain, spine, and neural tube development. Prevents birth defects.',
            localFoods: 'Palak (Spinach), Methi, Lentils (Dal), and Oranges.',
          ),
          SizedBox(height: 10),
          _NutrientCard(
            icon: Icons.spa_rounded,
            iconColor: Color(0xFF2E7D32),
            title: 'Morning Sickness Relief',
            badge: 'Daily Care',
            badgeColor: Color(0xFFA3F69C),
            badgeTextColor: Color(0xFF065F18),
            description:
                'Eat small, frequent dry meals (roasted chana, toast) before getting out of bed. Sip lemon-ginger water.',
            localFoods:
                'Lemon water, Ginger tea without excess sugar, Coconut water.',
          ),
          SizedBox(height: 10),
          _WellnessTile(
            icon: Icons.bedtime_rounded,
            title: 'Adequate Rest & First ANC Visit',
            description:
                'Register pregnancy at PHC for MCP card and TT-1 injection. Aim for 8 hours night sleep + 1 hour daytime rest.',
            iconBgColor: Color(0xFFE7EEFF),
            iconColor: AppColors.primary,
          ),
        ],
      );
    } else if (index == 1) {
      // 2nd Trimester
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _NutrientCard(
            icon: Icons.medication,
            iconColor: AppColors.secondary,
            title: 'Iron & Folic Acid (IFA)',
            badge: '1 Daily',
            badgeColor: Color(0xFFA3F69C),
            badgeTextColor: Color(0xFF065F18),
            description:
                'Take 1 tablet daily after meals with water or lemon water (never with tea/milk). Prevents anemia and boosts baby\'s blood supply.',
            localFoods:
                'Spinach (Palak), Jaggery (Gur), Drumsticks, Lentils & Beetroot.',
          ),
          SizedBox(height: 10),
          _NutrientCard(
            icon: Icons.health_and_safety,
            iconColor: AppColors.primary,
            title: 'Calcium & Vitamin D',
            badge: 'Afternoon',
            badgeColor: Color(0xFFE7EEFF),
            badgeTextColor: AppColors.primary,
            description:
                'Take 1 tablet after lunch (keep a 2-hour gap from Iron tablet). Critical for fetal bone, tooth, and skeletal development.',
            localFoods:
                'Milk, Fresh Curd, Ragi (Nachni), Paneer, and Sesame seeds.',
          ),
          SizedBox(height: 10),
          _WellnessTile(
            icon: Icons.hotel,
            title: 'Sleep on Left Side (L-Position)',
            description:
                'Sleeping on left side with a pillow between knees maximizes placental blood flow. Feel baby flutters (quickening).',
            iconBgColor: Color(0xFFE7EEFF),
            iconColor: AppColors.primary,
          ),
        ],
      );
    } else {
      // 3rd Trimester
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _NutrientCard(
            icon: Icons.bolt_rounded,
            iconColor: Color(0xFFF57F17),
            title: 'Energy & High-Fiber Meals',
            badge: '+450 kcal',
            badgeColor: Color(0xFFFFECB3),
            badgeTextColor: Color(0xFFF57F17),
            description:
                'Fetal weight accelerates rapidly. Eat small frequent high-fiber meals to prevent late-pregnancy constipation and heartburn.',
            localFoods:
                'Oats, Dalia, Khichdi with vegetables, Bananas, and Buttermilk.',
          ),
          SizedBox(height: 10),
          _NutrientCard(
            icon: Icons.inventory_2_rounded,
            iconColor: AppColors.primary,
            title: 'Hospital Bag & Birth Plan',
            badge: 'Ready by Wk 36',
            badgeColor: Color(0xFFE7EEFF),
            badgeTextColor: AppColors.primary,
            description:
                'Pack MCP Card, Aadhaar, baby clothes, clean towels, and identify 108 ambulance contact and blood donor.',
            localFoods:
                'Arrange transport to 24/7 delivery facility (PHC/District Hospital).',
          ),
          SizedBox(height: 10),
          _WellnessTile(
            icon: Icons.favorite_rounded,
            title: 'Fetal Movement Monitoring',
            description:
                'Count kicks daily after meals. You should feel at least 10 kicks in 2 hours. If movements drop, go immediately to hospital.',
            iconBgColor: Color(0xFFFFECB3),
            iconColor: Color(0xFFF57F17),
          ),
        ],
      );
    }
  }

  Widget _buildAiAssistantCard(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFD54F), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECB3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: Color(0xFFF57F17),
                ),
                SizedBox(width: 4),
                Text(
                  'Not a Doctor - AI Health Assistant',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57F17),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Have questions about mother or baby care?',
            textAlign: TextAlign.center,
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Ask our AI assistant about nutrition, vaccines, danger signs, or newborn care.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF506079),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: [
              _AiSuggestionChip(
                label: 'Pregnancy Nutrition',
                onTap: () => context.push(
                  AppRoutes.aiChat,
                  extra:
                      'What nutritious local foods should a pregnant mother eat?',
                ),
              ),
              _AiSuggestionChip(
                label: 'Vaccine Schedule',
                onTap: () => context.push(
                  AppRoutes.aiChat,
                  extra:
                      'Explain the essential childhood vaccines given in India at 6, 10, and 14 weeks.',
                ),
              ),
              _AiSuggestionChip(
                label: 'How to make ORS',
                onTap: () => context.push(
                  AppRoutes.aiChat,
                  extra: 'How do I prepare ORS for baby diarrhea at home?',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: () => context.push(
              AppRoutes.aiChat,
              extra:
                  'Hello! I have a question regarding maternal and child healthcare.',
            ),
            icon: const Icon(
              Icons.smart_toy_rounded,
              color: Colors.white,
              size: 20,
            ),
            label: Text(
              l10n.askPregnancyAi,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  ({String title, String emoji, String description}) _getBabySizeComparison(
      int week) {
    if (week <= 8) {
      return (
        title: 'Baby is size of a Raspberry (~1.6 cm)',
        emoji: '🍇',
        description:
            'Heart is beating and facial features are starting to form.',
      );
    } else if (week <= 13) {
      return (
        title: 'Baby is size of a Lemon (~7.5 cm)',
        emoji: '🍋',
        description: 'Vocal cords, fingerprints, and tiny nails are developing.',
      );
    } else if (week <= 20) {
      return (
        title: 'Baby is size of a Banana (~16 cm, 300g)',
        emoji: '🍌',
        description: 'Baby can hear your voice and swallows amniotic fluid.',
      );
    } else if (week <= 27) {
      return (
        title: 'Baby is size of an Ear of Corn (~35 cm, 750g)',
        emoji: '🌽',
        description: 'Lungs are maturing and eyes open. Baby kicks actively.',
      );
    } else if (week <= 34) {
      return (
        title: 'Baby is size of a Pineapple (~43 cm, 1.9 kg)',
        emoji: '🍍',
        description:
            'Bones are hardening and baby responds to light and sound.',
      );
    } else {
      return (
        title: 'Baby is size of a Watermelon (~50 cm, 3.2 kg)',
        emoji: '🍉',
        description:
            'Full term and ready for birth! Lungs are fully developed.',
      );
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _ModeSwitchButton extends StatelessWidget {
  const _ModeSwitchButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? const [
                  BoxShadow(
                    color: Color(0x15000000),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? AppColors.primary : const Color(0xFF506079),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? AppColors.primary : const Color(0xFF506079),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MaternalQuickActionCard extends StatelessWidget {
  const _MaternalQuickActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFD5E3FF)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: Color(0xFF24334A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF506079),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: AppColors.primary,
        backgroundColor: const Color(0xFFF0F3FF),
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF506079),
        ),
      ),
    );
  }
}

class _VaccineItemCard extends StatelessWidget {
  const _VaccineItemCard({
    required this.vaccine,
    required this.onToggle,
  });

  final ChildVaccine vaccine;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: vaccine.isCompleted
            ? const Color(0xFFF1F8E9)
            : const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: vaccine.isCompleted
              ? const Color(0xFFA3F69C)
              : const Color(0xFFD5E3FF),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: vaccine.isCompleted,
            activeColor: const Color(0xFF2E7D32),
            onChanged: (val) => onToggle(val ?? false),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        vaccine.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: vaccine.isCompleted
                              ? const Color(0xFF2E7D32)
                              : const Color(0xFF24334A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: vaccine.isCompleted
                            ? const Color(0xFFA3F69C)
                            : const Color(0xFFE7EEFF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        vaccine.ageGroup,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: vaccine.isCompleted
                              ? const Color(0xFF065F18)
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  vaccine.fullName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF506079),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prevents: ${vaccine.preventsDiseases.join(", ")}',
                  style: TextStyle(
                    fontSize: 11,
                    color: vaccine.isCompleted
                        ? const Color(0xFF33691E)
                        : const Color(0xFF506079),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Dose & Route: ${vaccine.dose} · ${vaccine.route} (${vaccine.site})',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF8A9BA8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NewbornCareTile extends StatelessWidget {
  const _NewbornCareTile({
    required this.icon,
    required this.title,
    required this.desc,
  });

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: const BoxDecoration(
            color: Color(0xFFE7EEFF),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 16),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF24334A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF506079),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _GovSchemeBullet extends StatelessWidget {
  const _GovSchemeBullet({
    required this.title,
    required this.desc,
  });

  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '• ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF33691E),
          ),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 12, color: Color(0xFF2E7D32)),
              children: [
                TextSpan(
                  text: '$title ',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: desc),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({
    required this.title,
    required this.isChecked,
    required this.onChanged,
  });

  final String title;
  final bool isChecked;
  final ValueChanged<bool?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: () => onChanged(!isChecked),
        borderRadius: BorderRadius.circular(8),
        child: Row(
          children: [
            Checkbox(
              value: isChecked,
              activeColor: AppColors.secondary,
              onChanged: onChanged,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: isChecked
                      ? AppColors.textSecondary
                      : const Color(0xFF24334A),
                  decoration: isChecked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NutrientCard extends StatelessWidget {
  const _NutrientCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.badge,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.description,
    required this.localFoods,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String badge;
  final Color badgeColor;
  final Color badgeTextColor;
  final String description;
  final String localFoods;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD5E3FF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: badgeTextColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            description,
            style: AppTextStyles.bodySmall.copyWith(
              color: const Color(0xFF506079),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.only(top: 6),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0xFFE7EEFF)),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Local Foods: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF24334A),
                  ),
                ),
                Expanded(
                  child: Text(
                    localFoods,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF506079),
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
}

class _WellnessTile extends StatelessWidget {
  const _WellnessTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBgColor,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color iconBgColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD5E3FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Color(0xFF24334A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF506079),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AiSuggestionChip extends StatelessWidget {
  const _AiSuggestionChip({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: Colors.white,
      side: const BorderSide(color: Color(0xFFFFD54F)),
      labelStyle: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: Color(0xFF5D4037),
      ),
    );
  }
}
