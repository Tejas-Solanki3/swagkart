// =============================================================================
// File: lib/core/widgets/empty_state.dart
// Purpose: Reusable empty state screen component displaying playful artwork, title,
//          explanatory subtitle, and an optional call-to-action button.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'swag_button.dart';

/// Reusable empty state visual placeholder.
///
/// Supports both SVG and raster asset paths for the illustration and
/// smoothly staggers entrance animations for the art, text, and button.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.image,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });


  final String image;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (image.endsWith('.svg')
                    ? SvgPicture.asset(
                        image,
                        width: 190,
                        height: 190,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        image,
                        width: 190,
                        height: 190,
                        fit: BoxFit.contain,
                      ))
                .animate()
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .moveY(begin: 24, end: 0, duration: 600.ms),
            const SizedBox(height: 20),
            Text(
                  title,
                  textAlign: TextAlign.center,
                  style: SwagTheme.display(size: 22),
                )
                .animate(delay: 180.ms)
                .fadeIn(duration: 400.ms)
                .moveY(begin: 14, end: 0, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: SwagTheme.body(size: 13, color: SwagColors.inkSoft),
                )
                .animate(delay: 280.ms)
                .fadeIn(duration: 400.ms)
                .moveY(begin: 14, end: 0, duration: 400.ms),
            if (actionLabel != null) ...[
              const SizedBox(height: 22),
              SizedBox(
                    width: 220,
                    child: SwagButton(
                      label: actionLabel!,
                      trailingIcon: 'arrow-right',
                      onTap: onAction,
                    ),
                  )
                  .animate(delay: 380.ms)
                  .fadeIn(duration: 400.ms)
                  .moveY(begin: 14, end: 0, duration: 400.ms),
            ],
          ],
        ),
      ),
    );
  }
}
