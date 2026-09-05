// Edit Profile Screen — allows the authenticated patient to view and update
// their profile details and health information.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _villageController;
  late final TextEditingController _districtController;
  late final TextEditingController _stateController;
  late final TextEditingController _abhaController;
  late final TextEditingController _emergencyNameController;
  late final TextEditingController _emergencyPhoneController;

  String _selectedGender = 'Female';
  bool _isPregnant = false;
  int _gestationalWeek = 12;
  String _selectedBloodGroup = "Don't Know";
  bool _isLoading = false;
  String? _errorMessage;
  bool _initialized = false;

  final List<String> _genders = ['Female', 'Male', 'Other'];
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
  };

  final Map<String, bool> _allergies = {
    'Penicillin': false,
    'Sulfa drugs': false,
    'Aspirin': false,
    'Dust / Pollen': false,
  };

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
    _villageController = TextEditingController();
    _districtController = TextEditingController();
    _stateController = TextEditingController();
    _abhaController = TextEditingController();
    _emergencyNameController = TextEditingController();
    _emergencyPhoneController = TextEditingController();
  }

  void _populateFromPatient(Patient patient) {
    if (_initialized) return;
    _initialized = true;

    _nameController.text = patient.name;
    _ageController.text = patient.age > 0 ? patient.age.toString() : '';
    _villageController.text = patient.village;
    _districtController.text = patient.district;
    _stateController.text = patient.state.isNotEmpty ? patient.state : 'Maharashtra';
    _abhaController.text = patient.abhaId;
    _emergencyNameController.text = patient.emergencyContactName;
    _emergencyPhoneController.text = patient.emergencyContactPhone;
    _isPregnant = patient.isPregnant;
    _gestationalWeek = patient.gestationalWeek ?? 12;

    if (_genders.contains(patient.gender)) {
      _selectedGender = patient.gender;
    }
    if (_bloodGroups.contains(patient.bloodGroup)) {
      _selectedBloodGroup = patient.bloodGroup;
    }

    for (final condition in patient.conditions) {
      if (_conditions.containsKey(condition)) {
        _conditions[condition] = true;
      }
    }

    for (final allergy in patient.allergies) {
      if (_allergies.containsKey(allergy)) {
        _allergies[allergy] = true;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _abhaController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile(Patient currentPatient) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final selectedConditions = _conditions.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final selectedAllergies = _allergies.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    final updated = currentPatient.copyWith(
      name: _nameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? currentPatient.age,
      gender: _selectedGender,
      isPregnant: _selectedGender == 'Female' ? _isPregnant : false,
      gestationalWeek: (_selectedGender == 'Female' && _isPregnant) ? _gestationalWeek : null,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
      abhaId: _abhaController.text.trim(),
      village: _villageController.text.trim(),
      district: _districtController.text.trim(),
      state: _stateController.text.trim(),
      bloodGroup: _selectedBloodGroup,
      allergies: selectedAllergies,
      conditions: selectedConditions,
    );

    try {
      final repo = ref.read(patientRepositoryProvider);
      await repo.updatePatient(updated);
      ref.invalidate(currentPatientProvider);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.secondary,
        ),
      );
      context.pop();
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to update profile. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final patientAsync = ref.watch(currentPatientProvider);

    return patientAsync.when(
      data: (patient) {
        _populateFromPatient(patient);
        return _buildForm(patient);
      },
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Edit Profile')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (err, stack) {
        final cached = ref.read(localStorageProvider).patientProfile;
        if (cached != null) {
          _populateFromPatient(cached);
          return _buildForm(cached);
        }
        return Scaffold(
          appBar: AppBar(title: const Text('Edit Profile')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppColors.emergency),
                const SizedBox(height: 16),
                Text('Could not load profile: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => ref.invalidate(currentPatientProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildForm(Patient patient) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
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
                // Personal Details
                Text('Personal Details', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Full Name',
                          hintText: 'e.g. Sunita Devi',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter your name'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Age
                      TextFormField(
                        controller: _ageController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                          if (age == null || age < 1 || age > 120) {
                            return 'Please enter a valid age (1-120)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Gender
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Gender', style: AppTextStyles.titleSmall),
                          const SizedBox(height: 8),
                          Row(
                            children: _genders.map((g) {
                              final selected = _selectedGender == g;
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    label: Text(g),
                                    selected: selected,
                                    onSelected: (_) =>
                                        setState(() => _selectedGender = g),
                                    selectedColor: AppColors.primaryContainer,
                                    labelStyle: AppTextStyles.labelMedium.copyWith(
                                      color: selected
                                          ? AppColors.primary
                                          : AppColors.textMuted,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          // Female Pregnancy Section
                          if (_selectedGender == 'Female') ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFCE4EC),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xFFF48FB1),
                                  width: 0.8,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.pregnant_woman_rounded,
                                        color: Color(0xFFC2185B),
                                        size: 22,
                                      ),
                                      const SizedBox(width: 8),
                                      const Expanded(
                                        child: Text(
                                          'Are you currently pregnant?',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF880E4F),
                                          ),
                                        ),
                                      ),
                                      Switch.adaptive(
                                        value: _isPregnant,
                                        activeThumbColor: const Color(0xFFC2185B),
                                        onChanged: (val) =>
                                            setState(() => _isPregnant = val),
                                      ),
                                    ],
                                  ),
                                  if (_isPregnant) ...[
                                    const SizedBox(height: 12),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Gestational Week: $_gestationalWeek',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF880E4F),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFC2185B),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            _gestationalWeek <= 12
                                                ? '1st Trimester'
                                                : _gestationalWeek <= 27
                                                    ? '2nd Trimester'
                                                    : '3rd Trimester',
                                            style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Slider(
                                      value: _gestationalWeek.toDouble(),
                                      min: 1,
                                      max: 40,
                                      divisions: 39,
                                      activeColor: const Color(0xFFC2185B),
                                      inactiveColor: const Color(0xFFF8BBD0),
                                      label: 'Week $_gestationalWeek',
                                      onChanged: (val) => setState(
                                          () => _gestationalWeek = val.round()),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Emergency Contact Details
                Text('Emergency Contact', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emergencyNameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Contact Person Name',
                          hintText: 'e.g. Ramesh Devi (Husband/Father)',
                          prefixIcon: Icon(Icons.emergency_outlined),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Phone Number',
                          hintText: 'e.g. +91 98765 43210',
                          prefixIcon: Icon(Icons.phone_in_talk_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Location Details
                Text('Location', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    children: [
                      // Village
                      TextFormField(
                        controller: _villageController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Village / Town',
                          hintText: 'e.g. Koregaon',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter your village'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // District
                      TextFormField(
                        controller: _districtController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'District',
                          hintText: 'e.g. Satara',
                          prefixIcon: Icon(Icons.map_outlined),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter your district'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // State
                      TextFormField(
                        controller: _stateController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'State',
                          hintText: 'e.g. Maharashtra',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty)
                            ? 'Please enter your state'
                            : null,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Health Details
                Text('Medical Information', style: AppTextStyles.headlineSmall),
                const SizedBox(height: 12),
                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ABHA ID
                      TextFormField(
                        controller: _abhaController,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'ABHA Health ID (Optional)',
                          hintText: 'e.g. 14-digit ABHA Number',
                          prefixIcon: Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text('Blood Group', style: AppTextStyles.titleMedium),
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
                            selectedColor: AppColors.primaryContainer,
                            labelStyle: AppTextStyles.labelMedium.copyWith(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Conditions
                      Text('Existing Conditions', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      ..._conditions.keys.map((c) => CheckboxListTile(
                            title: Text(c, style: AppTextStyles.bodyMedium),
                            value: _conditions[c],
                            onChanged: (val) =>
                                setState(() => _conditions[c] = val ?? false),
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )),
                      const SizedBox(height: 16),

                      // Allergies
                      Text('Known Allergies', style: AppTextStyles.titleMedium),
                      const SizedBox(height: 8),
                      ..._allergies.keys.map((a) => CheckboxListTile(
                            title: Text(a, style: AppTextStyles.bodyMedium),
                            value: _allergies[a],
                            onChanged: (val) =>
                                setState(() => _allergies[a] = val ?? false),
                            contentPadding: EdgeInsets.zero,
                            activeColor: AppColors.primary,
                            controlAffinity: ListTileControlAffinity.leading,
                            dense: true,
                          )),
                    ],
                  ),
                ),

                // Error message banner
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.emergency.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.emergency.withValues(alpha: 0.3),
                      ),
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
                  label: 'Save Changes',
                  onPressed: () => _saveProfile(patient),
                  isLoading: _isLoading,
                  icon: Icons.check_rounded,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
