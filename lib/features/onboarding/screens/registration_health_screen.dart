import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
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
  bool _isLoading = false;
  String? _errorMessage;

  String _selectedBloodGroup = 'Don\'t Know';
  final List<String> _bloodGroups = [
    'A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-', "Don't Know"
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
  void dispose() {
    _ageController.dispose();
    super.dispose();
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
        : (existingProfile?.name.isNotEmpty == true ? existingProfile!.name : 'Patient');

    final patientToSave = Patient(
      id: existingProfile?.id ?? '',
      name: name,
      phone: phone,
      age: int.tryParse(_ageController.text.trim()) ?? existingProfile?.age ?? 0,
      gender: extra['gender'] as String? ?? existingProfile?.gender ?? 'Female',
      village: extra['village'] as String? ?? existingProfile?.village ?? '',
      district: extra['district'] as String? ?? existingProfile?.district ?? '',
      state: extra['state'] as String? ?? existingProfile?.state ?? 'Maharashtra',
      bloodGroup: _selectedBloodGroup,
      allergies: selectedAllergies,
      conditions: selectedConditions,
    );

    // Save locally immediately to guarantee state is not lost
    await storage.savePatientProfile(patientToSave);
    await storage.setIsNewUser(false);

    try {
      final repo = ref.read(patientRepositoryProvider);
      final saved = await repo.updatePatient(patientToSave);
      await storage.savePatientProfile(saved);
    } catch (_) {
      // Backend sync error caught gracefully; local profile is already saved
    }

    ref.read(authNotifierProvider).notify();
    ref.invalidate(currentPatientProvider);

    if (!mounted) return;
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Health Information'),
        backgroundColor: AppColors.surface,
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
                // Progress indicator
                _buildProgress(step: 2),
                const SizedBox(height: 24),

                Text('Health Details', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'This helps doctors and healthcare workers understand your health better.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

                // Age
                SectionCard(
                  child: TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    style: AppTextStyles.bodyLarge,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g. 34',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixText: 'years',
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Please enter your age';
                      final age = int.tryParse(val);
                      if (age == null || age < 1 || age > 120) return 'Please enter a valid age';
                      return null;
                    },
                  ),
                ),

                const SizedBox(height: 16),

                // Blood Group
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blood Group', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 12),
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
                            selectedColor: AppColors.primaryContainer,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: selected ? AppColors.primary : AppColors.textMuted,
                            ),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Existing conditions
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Existing Health Conditions', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('Select all that apply',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      ..._conditions.keys.map((condition) {
                        return CheckboxListTile(
                          title: Text(condition, style: AppTextStyles.bodyMedium),
                          value: _conditions[condition],
                          onChanged: (val) =>
                              setState(() => _conditions[condition] = val ?? false),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Allergies
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Known Allergies', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 4),
                      Text('Select all that apply',
                          style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted)),
                      const SizedBox(height: 12),
                      ..._allergies.keys.map((allergy) {
                        return CheckboxListTile(
                          title: Text(allergy, style: AppTextStyles.bodyMedium),
                          value: _allergies[allergy],
                          onChanged: (val) =>
                              setState(() => _allergies[allergy] = val ?? false),
                          contentPadding: EdgeInsets.zero,
                          activeColor: AppColors.primary,
                          controlAffinity: ListTileControlAffinity.leading,
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Optional Aadhaar note
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Aadhaar is optional. You can add it later in your profile.',
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emergency.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.emergency.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            size: 16, color: AppColors.emergency),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.emergency),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                RuralCareButton(
                  label: 'Finish Registration',
                  onPressed: _finish,
                  isLoading: _isLoading,
                  icon: Icons.check_circle_outline,
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
      children: List.generate(3, (i) {
        final isActive = i <= step;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary : AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}
