import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/models/patient.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/widgets/section_card.dart';

class RegistrationContactScreen extends ConsumerStatefulWidget {
  const RegistrationContactScreen({super.key});

  @override
  ConsumerState<RegistrationContactScreen> createState() =>
      _RegistrationContactScreenState();
}

class _RegistrationContactScreenState
    extends ConsumerState<RegistrationContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _villageController = TextEditingController();
  final _districtController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  String _selectedGender = 'Female';
  bool _isPregnant = false;
  int _gestationalWeek = 24; // Default to mid-pregnancy (Month 6)
  bool _isLoading = false;

  final List<String> _genders = ['Female', 'Male', 'Other'];

  @override
  void initState() {
    super.initState();
    final profile = LocalStorageService.instance.patientProfile;
    if (profile != null) {
      if (profile.name.isNotEmpty) _nameController.text = profile.name;
      if (profile.village.isNotEmpty) _villageController.text = profile.village;
      if (profile.district.isNotEmpty) {
        _districtController.text = profile.district;
      }
      if (_genders.contains(profile.gender)) _selectedGender = profile.gender;
      _isPregnant = profile.isPregnant;
      if (profile.gestationalWeek != null && profile.gestationalWeek! > 0) {
        _gestationalWeek = profile.gestationalWeek!;
      }
      if (profile.emergencyContactName.isNotEmpty) {
        _emergencyNameController.text = profile.emergencyContactName;
      }
      if (profile.emergencyContactPhone.isNotEmpty) {
        _emergencyPhoneController.text = profile.emergencyContactPhone;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _villageController.dispose();
    _districtController.dispose();
    _pincodeController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  String _getTrimesterLabel(int week, AppLocalizations loc) {
    if (week <= 12) return loc.translate('firstTrimester');
    if (week <= 27) return loc.translate('secondTrimester');
    return loc.translate('thirdTrimester');
  }

  Future<void> _continue() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final village = _villageController.text.trim();
    final district = _districtController.text.trim();
    final isFemale = _selectedGender.toLowerCase() == 'female';
    final isPregnant = isFemale && _isPregnant;

    final contactData = {
      'name': name,
      'gender': _selectedGender,
      'isPregnant': isPregnant,
      'gestationalWeek': isPregnant ? _gestationalWeek : null,
      'village': village,
      'district': district,
      'pincode': _pincodeController.text.trim(),
      'state': 'Maharashtra',
      'emergencyContactName': _emergencyNameController.text.trim(),
      'emergencyContactPhone': _emergencyPhoneController.text.trim(),
    };

    // Save partial draft locally
    final storage = LocalStorageService.instance;
    final existing = storage.patientProfile;
    final draft = (existing ??
            Patient(
              id: '',
              name: name,
              phone: storage.patientPhone ?? '',
              age: 0,
              gender: _selectedGender,
              isPregnant: isPregnant,
              gestationalWeek: isPregnant ? _gestationalWeek : null,
              village: village,
              district: district,
              state: 'Maharashtra',
              bloodGroup: "Don't Know",
              emergencyContactName: _emergencyNameController.text.trim(),
              emergencyContactPhone: _emergencyPhoneController.text.trim(),
              allergies: const [],
              conditions: const [],
            ))
        .copyWith(
      name: name,
      gender: _selectedGender,
      isPregnant: isPregnant,
      gestationalWeek: isPregnant ? _gestationalWeek : null,
      village: village,
      district: district,
      emergencyContactName: _emergencyNameController.text.trim(),
      emergencyContactPhone: _emergencyPhoneController.text.trim(),
    );
    await storage.savePatientProfile(draft);

    setState(() => _isLoading = false);
    if (mounted) {
      context.go(AppRoutes.registerHealth, extra: contactData);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    final currentLang = LocalStorageService.instance.appLanguage;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          loc.translate('step1Of2'),
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surface,
        elevation: 0,
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
                // Language Quick Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.translate_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        loc.translate('preferredLanguage'),
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      _buildLangChip('English', 'en', currentLang),
                      const SizedBox(width: 4),
                      _buildLangChip('हिन्दी', 'hi', currentLang),
                      const SizedBox(width: 4),
                      _buildLangChip('বাংলা', 'bn', currentLang),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Progress indicator
                _buildProgress(step: 1),
                const SizedBox(height: 20),

                Text(
                  loc.translate('personalDetails'),
                  style: AppTextStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.translate('welcomeSubtitle'),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textMuted),
                ),
                const SizedBox(height: 20),

                SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Full Name
                      TextFormField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText: loc.translate('name'),
                          hintText: 'e.g. Sunita Devi / Krishanu',
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Please enter your name'
                                : null,
                      ),

                      const SizedBox(height: 18),

                      // Gender Selector
                      Text(
                        loc.translate('gender'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: _genders.map((g) {
                          final selected = _selectedGender == g;
                          final IconData icon = g == 'Female'
                              ? Icons.female_rounded
                              : (g == 'Male'
                                  ? Icons.male_rounded
                                  : Icons.transgender_rounded);

                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ChoiceChip(
                                avatar: Icon(
                                  icon,
                                  size: 16,
                                  color: selected
                                      ? Colors.white
                                      : AppColors.primary,
                                ),
                                label: Text(
                                  g == 'Female'
                                      ? loc.translate('genderFemale')
                                      : (g == 'Male'
                                          ? loc.translate('genderMale')
                                          : loc.translate('genderOther')),
                                ),
                                selected: selected,
                                onSelected: (_) {
                                  setState(() {
                                    _selectedGender = g;
                                    if (g != 'Female') {
                                      _isPregnant = false;
                                    }
                                  });
                                },
                                selectedColor: AppColors.primary,
                                labelStyle:
                                    AppTextStyles.labelMedium.copyWith(
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
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      // ── Conditional Pregnancy Inquiry Card (For Females) ──
                      if (_selectedGender.toLowerCase() == 'female') ...[
                        const SizedBox(height: 16),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: _isPregnant
                                ? const Color(0xFFFCE4EC)
                                : AppColors.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(
                                AppDimensions.radiusMd),
                            border: Border.all(
                              color: _isPregnant
                                  ? const Color(0xFFE91E63)
                                  : AppColors.outlineVariant,
                              width: _isPregnant ? 1.5 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: _isPregnant
                                          ? const Color(0xFFE91E63)
                                          : AppColors.primaryContainer,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.pregnant_woman_rounded,
                                      size: 18,
                                      color: _isPregnant
                                          ? Colors.white
                                          : AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      loc.translate('areYouPregnant'),
                                      style:
                                          AppTextStyles.titleSmall.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: _isPregnant
                                            ? const Color(0xFF880E4F)
                                            : AppColors.onSurface,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),

                              // Yes / No Toggle
                              Row(
                                children: [
                                  Expanded(
                                    child: ChoiceChip(
                                      label: Text(
                                          '🌸 ${loc.translate('yesPregnant')}'),
                                      selected: _isPregnant,
                                      onSelected: (val) {
                                        setState(() => _isPregnant = true);
                                      },
                                      selectedColor:
                                          const Color(0xFFE91E63),
                                      labelStyle: AppTextStyles.labelMedium
                                          .copyWith(
                                        color: _isPregnant
                                            ? Colors.white
                                            : AppColors.onSurface,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppDimensions.radiusSm),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ChoiceChip(
                                    label:
                                        Text(loc.translate('notPregnant')),
                                    selected: !_isPregnant,
                                    onSelected: (val) {
                                      setState(() => _isPregnant = false);
                                    },
                                    selectedColor: AppColors.primary,
                                    labelStyle: AppTextStyles.labelMedium
                                        .copyWith(
                                      color: !_isPregnant
                                          ? Colors.white
                                          : AppColors.onSurface,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppDimensions.radiusSm),
                                    ),
                                  ),
                                ],
                              ),

                              // If Pregnant: Month / Week slider
                              if (_isPregnant) ...[
                                const SizedBox(height: 14),
                                const Divider(),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${loc.translate('gestationalWeekLabel')}: Week $_gestationalWeek (Month ${((_gestationalWeek / 4.3).ceil()).clamp(1, 9)})',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF880E4F),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE91E63),
                                        borderRadius:
                                            BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        _getTrimesterLabel(
                                            _gestationalWeek, loc),
                                        style: AppTextStyles.labelSmall
                                            .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 10,
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
                                  activeColor: const Color(0xFFE91E63),
                                  inactiveColor: const Color(0xFFF8BBD0),
                                  label: 'Week $_gestationalWeek',
                                  onChanged: (val) {
                                    setState(
                                        () => _gestationalWeek = val.round());
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 18),

                      // Village / Town
                      TextFormField(
                        controller: _villageController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText: loc.translate('villageLabel'),
                          hintText: 'e.g. Koregaon / Prafulla Nagar',
                          prefixIcon:
                              const Icon(Icons.location_city_outlined),
                        ),
                        validator: (val) =>
                            (val == null || val.trim().isEmpty)
                                ? 'Please enter your village / town'
                                : null,
                      ),

                      const SizedBox(height: 16),

                      // District & Pincode Row
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: TextFormField(
                              controller: _districtController,
                              textCapitalization: TextCapitalization.words,
                              style: AppTextStyles.bodyLarge,
                              decoration: InputDecoration(
                                labelText: loc.translate('districtLabel'),
                                hintText: 'e.g. Satara / Kolkata',
                                prefixIcon: const Icon(Icons.map_outlined),
                              ),
                              validator: (val) =>
                                  (val == null || val.trim().isEmpty)
                                      ? 'Please enter district'
                                      : null,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _pincodeController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              maxLength: 6,
                              style: AppTextStyles.bodyLarge,
                              decoration: InputDecoration(
                                labelText: loc.translate('pincodeLabel'),
                                hintText: '415501',
                                counterText: '',
                                prefixIcon: const Icon(Icons.pin_outlined),
                              ),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Enter PIN';
                                }
                                if (val.length < 6) return '6 digits';
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      // Emergency Contact Section
                      Text(
                        loc.translate('emergencyContactSection'),
                        style: AppTextStyles.titleSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        controller: _emergencyNameController,
                        textCapitalization: TextCapitalization.words,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText:
                              loc.translate('emergencyContactNameLabel'),
                          hintText: loc.translate('emergencyContactHint'),
                          prefixIcon: const Icon(Icons.contact_phone_outlined),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: _emergencyPhoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        maxLength: 10,
                        style: AppTextStyles.bodyLarge,
                        decoration: InputDecoration(
                          labelText:
                              loc.translate('emergencyContactPhoneLabel'),
                          hintText: '10-digit mobile number',
                          counterText: '',
                          prefixIcon: const Icon(Icons.phone_outlined),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                RuralCareButton(
                  label: loc.translate('continueBtn'),
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

  Widget _buildLangChip(String label, String code, String currentLang) {
    final isSelected = currentLang == code;
    return GestureDetector(
      onTap: () {
        ref.read(localeProvider.notifier).setLanguage(code);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.outlineVariant,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.labelSmall.copyWith(
            color: isSelected ? Colors.white : AppColors.onSurface,
            fontWeight: FontWeight.bold,
            fontSize: 11,
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
