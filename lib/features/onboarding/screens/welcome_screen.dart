import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/language_selector_modal.dart';
import '../../../core/widgets/ruralcare_button.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final currentLocale = ref.watch(localeProvider);

    final langNames = {
      'en': 'English',
      'hi': 'हिन्दी',
      'bn': 'বাংলা',
    };
    final currentLangName = langNames[currentLocale.languageCode] ?? 'English';

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenPadding),
          child: Column(
            children: [
              const Spacer(flex: 1),

              // Illustration / logo area
              Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 88,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // App name
              Text(
                AppConstants.appName,
                style: AppTextStyles.displayLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                l10n.welcomeTitle,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                l10n.welcomeSubtitle,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Get started button
              RuralCareButton(
                label: l10n.getStarted,
                onPressed: () => context.go(AppRoutes.login),
                icon: Icons.arrow_forward_rounded,
              ),

              const SizedBox(height: 14),

              // Emergency access — always visible even before login
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.emergency),
                icon: const Icon(Icons.emergency, size: 20),
                label: Text(
                  currentLocale.languageCode == 'bn'
                      ? 'জরুরী সহায়তা — ১০৮'
                      : currentLocale.languageCode == 'hi'
                          ? 'आपातकालीन सहायता — 108'
                          : 'Help Now — Emergency (108)',
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                  foregroundColor: AppColors.emergency,
                  side: const BorderSide(color: AppColors.emergency, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  textStyle: AppTextStyles.labelLarge,
                ),
              ),

              const SizedBox(height: 24),

              // Language selector pill
              InkWell(
                onTap: () => LanguageSelectorModal.show(context),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.language_rounded, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        '$currentLangName · ${l10n.changeLanguage}',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
