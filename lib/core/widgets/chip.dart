import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';
import 'swag_icon.dart';

/// Pill filter chip with a springy selected state.
class SwagChip extends StatelessWidget {
  const SwagChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.icon,
    this.activeColor = SwagColors.ink,
    this.fontSize = 13,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final String? icon;
  final Color activeColor;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? activeColor : SwagColors.surfaceMist,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? activeColor : Colors.transparent,
            width: 1.4,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              SwagIcon(
                icon!,
                size: 15,
                color: selected ? SwagColors.surface : SwagColors.inkSoft,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: SwagTheme.body(
                size: fontSize,
                weight: selected ? FontWeight.w700 : FontWeight.w600,
                color: selected ? SwagColors.surface : SwagColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
