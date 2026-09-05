import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class HealthcareCategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final bool isEmergency;
  final VoidCallback onTap;

  const HealthcareCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    required this.isSelected,
    this.isEmergency = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic theme colors for emergency vs regular categories
    final Color bgColor = isEmergency
        ? (isSelected ? const Color(0xFFD32F2F) : const Color(0xFFFFF1F2))
        : (isSelected ? AppColors.primary : const Color(0xFFF8FAFC));

    final Color textColor = isEmergency
        ? (isSelected ? Colors.white : const Color(0xFFD32F2F))
        : (isSelected ? Colors.white : const Color(0xFF334155));

    final Color iconColor = isEmergency
        ? (isSelected ? Colors.white : const Color(0xFFD32F2F))
        : (isSelected ? Colors.white : AppColors.primary);

    final Color borderColor = isEmergency
        ? (isSelected ? const Color(0xFFB71C1C) : const Color(0xFFFFCDD2))
        : (isSelected
            ? AppColors.primary
            : const Color(0xFFE2E8F0));

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 1.4 : 1.0,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: isEmergency
                          ? const Color(0xFFD32F2F).withValues(alpha: 0.28)
                          : AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [
                    const BoxShadow(
                      color: Color(0x06000000),
                      blurRadius: 2,
                      offset: Offset(0, 1),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Icon(icon, size: 14, color: iconColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    fontSize: 11.5,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
