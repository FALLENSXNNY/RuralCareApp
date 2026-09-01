import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/models/patient.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class RegistrationContactScreen extends StatefulWidget {
  const RegistrationContactScreen({super.key});

  @override
  State<RegistrationContactScreen> createState() => _RegistrationContactScreenState();
}

class _RegistrationContactScreenState extends State<RegistrationContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  String _selectedGender = 'Female';
  bool _isLoading = false;

  final List<String> _genders = ['Female', 'Male', 'Other'];

  @override
  void initState() {
    super.initState();
    final profile = LocalStorageService.instance.patientProfile;
    if (profile != null) {
      if (profile.name.isNotEmpty) _nameController.text = profile.name;
      if (profile.village.isNotEmpty) _villageController.text = profile.village;
      if (profile.district.isNotEmpty) _districtController.text = profile.district;
      if (_genders.contains(profile.gender)) _selectedGender = profile.gender;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final village = _villageController.text.trim();
    final district = _districtController.text.trim();

    final contactData = {
      'name': name,
      'gender': _selectedGender,
      'village': village,
      'district': district,
      'pincode': _pincodeController.text.trim(),
      'state': 'Maharashtra',
    };

    // Save partial draft locally so data is not lost across reloads
    final storage = LocalStorageService.instance;
    final existing = storage.patientProfile;
    final draft = (existing ?? Patient(
      id: '',
      name: name,
      phone: storage.patientPhone ?? '',
      age: 0,
      gender: _selectedGender,
      village: village,
      district: district,
      state: 'Maharashtra',
      bloodGroup: "Don't Know",
      allergies: const [],
      conditions: const [],
    )).copyWith(
      name: name,
      gender: _selectedGender,
      village: village,
      district: district,
    );
    await storage.savePatientProfile(draft);

    setState(() => _isLoading = false);
    if (mounted) {
      context.go(AppRoutes.registerHealth, extra: contactData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceVariant,
      appBar: AppBar(
        title: const Text('Create Your Account'),
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.login),
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
                _buildProgress(step: 1),
                const SizedBox(height: 24),

                Text('Your Details', style: AppTextStyles.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Tell us a little about yourself so we can help you better.',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 24),

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
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Please enter your name' : null,
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
                                      color:
                                          selected ? AppColors.primary : AppColors.textMuted,
                                    ),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Village / Town
                      TextFormField(
                        controller: _villageController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'Village / Town',
                          hintText: 'e.g. Koregaon',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Please enter your village' : null,
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
                        validator: (val) =>
                            (val == null || val.trim().isEmpty) ? 'Please enter your district' : null,
                      ),

                      const SizedBox(height: 16),

                      // Pincode
                      TextFormField(
                        controller: _pincodeController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        maxLength: 6,
                        style: AppTextStyles.bodyLarge,
                        decoration: const InputDecoration(
                          labelText: 'PIN Code',
                          hintText: '415501',
                          prefixIcon: Icon(Icons.pin_outlined),
                          counterText: '',
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Please enter PIN code';
                          if (val.length < 6) return 'PIN code must be 6 digits';
                          return null;
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                RuralCareButton(
                  label: 'Continue',
                  onPressed: _continue,
                  isLoading: _isLoading,
                  icon: Icons.arrow_forward_rounded,
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
        final isActive = i < step;
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
