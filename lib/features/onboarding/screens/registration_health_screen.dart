import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/patient.dart';
import '../../../core/models/pregnancy.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utilities/pregnancy_calculator.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class RegistrationHealthScreen extends ConsumerStatefulWidget {
  const RegistrationHealthScreen({super.key, this.contactData});

  final Map<String, dynamic>? contactData;

  @override
  ConsumerState<RegistrationHealthScreen> createState() =>
      _RegistrationHealthScreenState();
}

class _RegistrationHealthScreenState
    extends ConsumerState<RegistrationHealthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _abhaController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedBloodGroup = "Don't Know";
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'O+',
    'O-',
    'AB+',
    'AB-',
    "Don't Know"
  ];

  final Map<String, bool> _conditions = {
    'Diabetes': false,
    'Hypertension (High BP)': false,
    'Heart Disease': false,
    'Asthma': false,
    'Anaemia': false,
    'Thyroid': false,
    'Kidney Disease': false,
    'None': false,
  };

  final Map<String, bool> _allergies = {
    'Penicillin': false,
    'Sulfa drugs': false,
    'Aspirin': false,
    'Dust / Pollen': false,
    'None': false,
  };

  @override
  void initState() {
    super.initState();
    final profile = LocalStorageService.instance.patientProfile;
    if (profile != null) {
      if (profile.age > 0) _ageController.text = profile.age.toString();
      if (_bloodGroups.contains(profile.bloodGroup)) {
        _selectedBloodGroup = profile.bloodGroup;
      }
      if (profile.abhaId.isNotEmpty) {
        _abhaController.text = profile.abhaId;
      }
      for (final c in profile.conditions) {
        if (_conditions.containsKey(c)) _conditions[c] = true;
      }
      for (final a in profile.allergies) {
        if (_allergies.containsKey(a)) _allergies[a] = true;
      }
    }
  }

  @override
  void dispose() {
    _ageController.dispose();
    _abhaController.dispose();
    super.dispose();
  }

  void _toggleCondition(String key) {
    setState(() {
      if (key == 'None') {
        final current = _conditions['None'] ?? false;
        _conditions.updateAll((k, v) => false);
        _conditions['None'] = !current;
      } else {
        _conditions['None'] = false;
        _conditions[key] = !(_conditions[key] ?? false);
      }
    });
  }

  void _toggleAllergy(String key) {
    setState(() {
      if (key == 'None') {
        final current = _allergies['None'] ?? false;
        _allergies.updateAll((k, v) => false);
        _allergies['None'] = !current;
      } else {
        _allergies['None'] = false;
        _allergies[key] = !(_allergies[key] ?? false);
      }
    });
  }

  Future<void> _finish() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final extra = widget.contactData ??
        (GoRouterState.of(context).extra as Map<String, dynamic>?) ??
        const {};

    final selectedConditions = _conditions.entries
        .where((e) => e.value && e.key != 'None')
        .map((e) => e.key)
        .toList();

    final selectedAllergies = _allergies.entries
        .where((e) => e.value && e.key != 'None')
        .map((e) => e.key)
        .toList();

    final storage = LocalStorageService.instance;
    final phone = storage.patientPhone ?? '';
    final existingProfile = storage.patientProfile;

    final name = (extra['name'] as String?)?.trim().isNotEmpty == true
        ? (extra['name'] as String).trim()
        : (existingProfile?.name.isNotEmpty == true
            ? existingProfile!.name
            : 'Patient');

    final isPregnant = extra['isPregnant'] as bool? ??
        existingProfile?.isPregnant ??
        false;
    final gestationalWeek = extra['gestationalWeek'] as int? ??
        existingProfile?.gestationalWeek;

    final patientToSave = Patient(
      id: existingProfile?.id.isNotEmpty == true
          ? existingProfile!.id
          : (phone.isNotEmpty ? 'patient_$phone' : 'patient_current'),
      name: name,
      phone: phone,
      age: int.tryParse(_ageController.text.trim()) ??
          existingProfile?.age ??
          28,
      gender: extra['gender'] as String? ??
          existingProfile?.gender ??
          'Female',
      isPregnant: isPregnant,
      gestationalWeek: gestationalWeek,
      village:
          extra['village'] as String? ?? existingProfile?.village ?? '',
      district:
          extra['district'] as String? ?? existingProfile?.district ?? '',
      state: extra['state'] as String? ??
          existingProfile?.state ??
          'Maharashtra',
      bloodGroup: _selectedBloodGroup,
      emergencyContactName: extra['emergencyContactName'] as String? ??
          existingProfile?.emergencyContactName ??
          '',
      emergencyContactPhone: extra['emergencyContactPhone'] as String? ??
          existingProfile?.emergencyContactPhone ??
          '',
      abhaId: _abhaController.text.trim(),
      preferredLanguage: storage.appLanguage,
      allergies: selectedAllergies,
      conditions: selectedConditions,
    );

    // Save locally immediately to guarantee persistence
    await storage.savePatientProfile(patientToSave);
    await storage.setIsNewUser(false);

    // If pregnant, also initialize/update PregnancyProfile
    if (isPregnant && gestationalWeek != null) {
      try {
        final pregRepo = ref.read(pregnancyRepositoryProvider);
        final now = DateTime.now();
        final daysRemaining = ((40 - gestationalWeek) * 7).clamp(0, 280);
        final calculatedEdd = now.add(Duration(days: daysRemaining));
        final calculatedLmp =
            PregnancyCalculator.calculateLmpFromEdd(calculatedEdd);

        final pregProfile = PregnancyProfile(
          id: 'preg_${patientToSave.id}',
          patientId: patientToSave.id,
          isPregnant: true,
          estimatedDueDate: calculatedEdd,
          lastMenstrualPeriod: calculatedLmp,
          currentWeek: gestationalWeek,
          riskLevel: PregnancyRiskLevel.normal,
          primaryHealthCenter:
              '${patientToSave.district} PHC / Sub-district Hospital',
          doctorOrAshaWorker:
              patientToSave.emergencyContactName.isNotEmpty
                  ? '${patientToSave.emergencyContactName} (Contact)'
                  : 'Sunita Tai (ASHA Worker)',
          notes:
              'Antenatal monitoring registered. Gestational Week $gestationalWeek.',
          updatedAt: now,
        );

        await pregRepo.savePregnancyProfile(pregProfile);
      } catch (_) {}
    }

    try {
      final repo = ref.read(patientRepositoryProvider);
      final saved = await repo.updatePatient(patientToSave);
      await storage.savePatientProfile(saved);
    } catch (_) {
      // Offline fallback: profile already saved locally
    }

    ref.read(authNotifierProvider).notify();
    ref.invalidate(currentPatientProvider);
    ref.invalidate(pregnancyProfileProvider);

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.translate('step2Of2'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.registerContact),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.screenPadding),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Progress indicator (Step 2 of 2)
                _buildProgress(step: 2),
                const SizedBox(height: 20),

                Text(
                  loc.translate('healthDetails'),
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('healthDetailsSubtitle'),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                if (_errorMessage != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emergencyRed.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                      border: Border.all(color: AppColors.emergencyRed),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.emergencyRed),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.emergencyRed),
                          ),
                        ),
                      ],
                    ),
                  ),

                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Age
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 3,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText: loc.translate('age'),
                          hintText: 'e.g. 28',
                          counterText: '',
                          prefixIcon: const Icon(Icons.cake_outlined),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Please enter your age';
                          }
                          final age = int.tryParse(val.trim());
                          if (age == null || age < 1 || age > 120) {
                            return 'Please enter a valid age (1-120)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),

                      // ABHA ID (Optional)
                      TextFormField(
                        controller: _abhaController,
                        keyboardType: TextInputType.number,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText: loc.translate('abhaIdLabel'),
                          hintText: loc.translate('abhaIdHint'),
                          prefixIcon: const Icon(Icons.credit_card_outlined),
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Blood Group Selection
                      Text(
                        loc.translate('bloodGroup'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _bloodGroups.map((bg) {
                          final selected = _selectedBloodGroup == bg;
                          return ChoiceChip(
                            label: Text(bg),
                            selected: selected,
                            onSelected: (_) =>
                                setState(() => _selectedBloodGroup = bg),
                            selectedColor: AppColors.primary,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: selected
                                  ? Colors.white
                                  : AppColors.onSurface,
                              fontWeight: FontWeight.bold,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                              side: BorderSide(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Chronic Conditions Multi-select
                      Text(
                        loc.translate('chronicConditions'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _conditions.keys.map((c) {
                          final isSelected = _conditions[c] ?? false;
                          return FilterChip(
                            label: Text(c),
                            selected: isSelected,
                            onSelected: (_) => _toggleCondition(c),
                            selectedColor:
                                AppColors.warning.withValues(alpha: 0.2),
                            checkmarkColor: AppColors.warning,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.onSurface
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.warning
                                    : AppColors.outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 22),

                      // Known Allergies Multi-select
                      Text(
                        loc.translate('allergies'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _allergies.keys.map((a) {
                          final isSelected = _allergies[a] ?? false;
                          return FilterChip(
                            label: Text(a),
                            selected: isSelected,
                            onSelected: (_) => _toggleAllergy(a),
                            selectedColor:
                                AppColors.emergencyRed.withValues(alpha: 0.15),
                            checkmarkColor: AppColors.emergencyRed,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: isSelected
                                  ? AppColors.emergencyRed
                                  : AppColors.textMuted,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusMd),
                              side: BorderSide(
                                color: isSelected
                                    ? AppColors.emergencyRed
                                    : AppColors.outlineVariant,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                RuralCareButton(
                  label: loc.translate('completeRegistration'),
                  onPressed: _finish,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline_rounded,
                ),

                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgress({required int step}) {
    return Row(
      children: List.generate(2, (i) {
        final isActive = i < step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 1 ? 6 : 0),
            height: 5,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
        );
      }),
    );
  }
}
