import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/ruralcare_button.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/router/app_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.health_and_safety_outlined,
                    size: 96,
                    color: AppColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: 40),

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
                AppConstants.appTagline,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                'Free healthcare support for rural communities in India.',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 2),

              // Get started button
              RuralCareButton(
                label: 'Get Started',
                onPressed: () => context.go(AppRoutes.login),
                icon: Icons.arrow_forward_rounded,
              ),

              const SizedBox(height: 16),

              // Emergency access — always visible even before login
              OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.emergency),
                icon: const Icon(Icons.emergency, size: 20),
                label: const Text('Help Now — Emergency'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  foregroundColor: AppColors.emergency,
                  side: const BorderSide(color: AppColors.emergency, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  textStyle: AppTextStyles.labelLarge,
                ),
              ),

              const SizedBox(height: 32),

              // Language note
              Text(
                'Available in English',
                style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
