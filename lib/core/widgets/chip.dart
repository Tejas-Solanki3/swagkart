// =============================================================================
// File: lib/core/widgets/chip.dart
// Purpose: Selectable interactive pill chips for customer category filtering
//          and dark-mode status chips for the merchant admin console.
// =============================================================================

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';
import 'swag_icon.dart';

/// Pill filter chip with a springy selected state used in customer storefront rails.
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

/// Dark-themed pill filter chip used in the admin console.
class AdminChip extends StatelessWidget {
  const AdminChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? badge;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    return Pressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? SwagColors.butter
              : Colors.white.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? SwagColors.butter
                : Colors.white.withValues(alpha: 0.14),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              const Icon(Icons.check_rounded, size: 14, color: SwagColors.ink),
              const SizedBox(width: 5),
            ] else if (icon != null) ...[
              SwagIcon(
                icon!,
                size: 13,
                color: SwagColors.canvas.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 5),
            ],
            Text(
              label,
              style: SwagTheme.body(
                size: 12,
                weight: selected ? FontWeight.w800 : FontWeight.w600,
                color: selected
                    ? SwagColors.ink
                    : SwagColors.canvas.withValues(alpha: 0.85),
              ),
            ),
            if (badge != null && badge!.isNotEmpty) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? SwagColors.ink.withValues(alpha: 0.15)
                      : Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badge!,
                  style: SwagTheme.body(
                    size: 10,
                    weight: FontWeight.w800,
                    color: selected ? SwagColors.ink : SwagColors.canvas,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
