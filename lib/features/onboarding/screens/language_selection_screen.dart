import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/storage/local_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';

class LanguageSelectionScreen extends ConsumerStatefulWidget {
  const LanguageSelectionScreen({super.key, this.isInitialOnboarding = true});

  final bool isInitialOnboarding;

  @override
  ConsumerState<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState
    extends ConsumerState<LanguageSelectionScreen> {
  late String _selectedLanguageCode;

  final List<Map<String, String>> _languages = const [
    {
      'code': 'en',
      'nativeName': 'English',
      'englishName': 'English',
      'welcomeText': 'Welcome to RuralCare',
      'subtitle': 'Select your preferred language',
      'badge': 'EN',
    },
    {
      'code': 'hi',
      'nativeName': 'हिन्दी',
      'englishName': 'Hindi',
      'welcomeText': 'रूरलकेयर में आपका स्वागत है',
      'subtitle': 'अपनी पसंदीदा भाषा चुनें',
      'badge': 'HI',
    },
    {
      'code': 'bn',
      'nativeName': 'বাংলা',
      'englishName': 'Bengali',
      'welcomeText': 'রুরালকেয়ারে স্বাগতম',
      'subtitle': 'আপনার পছন্দের ভাষা বেছে নিন',
      'badge': 'BN',
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode =
        ref.read(localStorageProvider).appLanguage.isNotEmpty
            ? ref.read(localStorageProvider).appLanguage
            : 'en';
  }

  Future<void> _onContinue() async {
    await ref.read(localeProvider.notifier).setLocale(_selectedLanguageCode);
    await ref.read(localStorageProvider).setHasSelectedLanguage(true);

    if (mounted) {
      if (widget.isInitialOnboarding) {
        context.go(AppRoutes.welcome);
      } else {
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedLang = _languages.firstWhere(
      (l) => l['code'] == _selectedLanguageCode,
      orElse: () => _languages.first,
    );

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              // Header Logo & Icons
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.translate_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Multilingual Title
              Text(
                'Choose Language\nभाषा चुनें / ভাষা নির্বাচন',
                style: AppTextStyles.headlineSmall.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                selectedLang['subtitle'] ?? 'Select your preferred language',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              // Language Cards
              Expanded(
                child: ListView.separated(
                  physics: const BouncingScrollPhysics(),
                  itemCount: _languages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final lang = _languages[index];
                    final isSelected = _selectedLanguageCode == lang['code'];

                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedLanguageCode = lang['code']!;
                        });
                        // Update app locale on the fly so UI responds immediately
                        ref
                            .read(localeProvider.notifier)
                            .setLocale(lang['code']!);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.border,
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(
                                      alpha: 0.15,
                                    ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Row(
                          children: [
                            // Badge / Circle
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: isSelected
                                  ? AppColors.primary
                                  : AppColors.surfaceContainer,
                              child: Text(
                                lang['badge']!,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),

                            // Language names
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lang['nativeName']!,
                                    style: AppTextStyles.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppColors.textPrimary,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    lang['englishName']!,
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Radio / Checkmark icon
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textMuted,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Continue Button
              RuralCareButton(
                label: _getContinueLabel(_selectedLanguageCode),
                onPressed: _onContinue,
                icon: Icons.arrow_forward_rounded,
              ),

              const SizedBox(height: 12),

              // Emergency access button — always available
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.emergency),
                icon: const Icon(Icons.emergency, size: 20),
                label: Text(_getEmergencyLabel(_selectedLanguageCode)),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 52),
                  foregroundColor: AppColors.emergency,
                  side: const BorderSide(
                    color: AppColors.emergency,
                    width: 1.5,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadius,
                    ),
                  ),
                  textStyle: AppTextStyles.labelLarge,
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  String _getContinueLabel(String code) {
    switch (code) {
      case 'hi':
        return 'आगे बढ़ें';
      case 'bn':
        return 'এগিয়ে যান';
      case 'en':
      default:
        return 'Continue';
    }
  }

  String _getEmergencyLabel(String code) {
    switch (code) {
      case 'hi':
        return 'आपातकालीन सहायता (108)';
      case 'bn':
        return 'জরুরী সহায়তা (108)';
      case 'en':
      default:
        return 'Help Now — Emergency (108)';
    }
  }
}
