// AI Disclaimer Banner — required on every AI output screen (agents.md Rule 20)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AiDisclaimerBanner extends StatelessWidget {
  const AiDisclaimerBanner({super.key, this.compact = false});

  /// When true, shows a smaller inline version (e.g. above each AI message)
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
            const SizedBox(width: 6),
            Text(
              'AI Health Assistant — Not a Doctor',
              style: AppTextStyles.aiDisclaimer,
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        border: Border(
          bottom: BorderSide(color: AppColors.warning.withValues(alpha: 0.3)),
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.health_and_safety_outlined, size: 20, color: AppColors.warning),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Health Assistant — Not a Doctor',
                  style: AppTextStyles.aiDisclaimer,
                ),
                const SizedBox(height: 2),
                Text(
                  'This assistant gives general health information only. Always consult a real doctor for medical advice.',
                  style: AppTextStyles.bodySmall.copyWith(color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
