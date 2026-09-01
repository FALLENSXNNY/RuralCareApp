// Offline banner — yellow, wifi_off icon, required by agents.md Rule 26
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, this.message = 'No internet connection'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.offlineBanner,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 20, color: AppColors.offlineBannerText),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.offlineBannerText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
