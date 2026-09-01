// RuralCare primary button — always 56dp minimum height
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum RuralCareButtonVariant { primary, secondary, danger, outline }

class RuralCareButton extends StatelessWidget {
  const RuralCareButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = RuralCareButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.minHeight = 56,
    this.width = double.infinity,
  });

  final String label;
  final VoidCallback? onPressed;
  final RuralCareButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final double minHeight;
  final double width;

  @override
  Widget build(BuildContext context) {
    final child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Colors.white,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.labelLarge),
            ],
          );

    switch (variant) {
      case RuralCareButtonVariant.primary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width, minHeight),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );

      case RuralCareButtonVariant.secondary:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width, minHeight),
              backgroundColor: AppColors.secondary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );

      case RuralCareButtonVariant.danger:
        return SizedBox(
          width: width,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              minimumSize: Size(width, minHeight),
              backgroundColor: AppColors.emergency,
              foregroundColor: AppColors.textOnEmergency,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );

      case RuralCareButtonVariant.outline:
        return SizedBox(
          width: width,
          child: OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width, minHeight),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: AppTextStyles.labelLarge,
            ),
            child: child,
          ),
        );
    }
  }
}
