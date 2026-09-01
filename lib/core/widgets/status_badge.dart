// Status badge — always Color + Icon + Text (agents.md Rule 25)
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

enum StatusType { active, pending, completed, cancelled, emergency, info }

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.status,
    this.customLabel,
    this.customIcon,
    this.customColor,
  });

  final StatusType status;
  final String? customLabel;
  final IconData? customIcon;
  final Color? customColor;

  _StatusConfig get _config {
    switch (status) {
      case StatusType.active:
        return _StatusConfig(
          label: customLabel ?? 'Active',
          icon: customIcon ?? Icons.check_circle,
          color: customColor ?? AppColors.success,
          background: AppColors.secondaryContainer,
        );
      case StatusType.pending:
        return _StatusConfig(
          label: customLabel ?? 'Pending',
          icon: customIcon ?? Icons.schedule,
          color: customColor ?? AppColors.warning,
          background: const Color(0xFFFFF8E1),
        );
      case StatusType.completed:
        return _StatusConfig(
          label: customLabel ?? 'Completed',
          icon: customIcon ?? Icons.done_all,
          color: customColor ?? AppColors.primary,
          background: AppColors.primaryContainer,
        );
      case StatusType.cancelled:
        return _StatusConfig(
          label: customLabel ?? 'Cancelled',
          icon: customIcon ?? Icons.cancel_outlined,
          color: customColor ?? AppColors.textMuted,
          background: AppColors.surfaceContainer,
        );
      case StatusType.emergency:
        return _StatusConfig(
          label: customLabel ?? 'Emergency',
          icon: customIcon ?? Icons.emergency,
          color: customColor ?? AppColors.emergency,
          background: AppColors.emergencyContainer,
        );
      case StatusType.info:
        return _StatusConfig(
          label: customLabel ?? 'Info',
          icon: customIcon ?? Icons.info_outline,
          color: customColor ?? AppColors.info,
          background: AppColors.primaryContainer,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _config;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: config.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, size: 14, color: config.color),
          const SizedBox(width: 5),
          Text(
            config.label,
            style: AppTextStyles.labelSmall.copyWith(color: config.color),
          ),
        ],
      ),
    );
  }
}

class _StatusConfig {
  final String label;
  final IconData icon;
  final Color color;
  final Color background;

  const _StatusConfig({
    required this.label,
    required this.icon,
    required this.color,
    required this.background,
  });
}
