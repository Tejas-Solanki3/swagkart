// =============================================================================
// File: lib/core/widgets/swag_logo.dart
// Purpose: Official SwagKart brand logo widget rendering the squircle app icon SVG
//          alongside stylized display typography with optional tap handling.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'pressable.dart';

/// Official SwagKart brand logo widget for top-left headers and navigation bars.
///
/// Features:
/// - Squircle brand mark with soft elevation shadow
/// - Optional 'SwagKart' typography in Baloo 2 font
/// - Wraps with [Pressable] if an [onTap] handler is supplied
class SwagLogo extends StatelessWidget {
  const SwagLogo({
    super.key,
    this.size = 32,
    this.showText = true,
    this.textColor,
    this.onTap,
  });


  final double size;
  final bool showText;
  final Color? textColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.28),
              boxShadow: [
                BoxShadow(
                  color: SwagColors.ink.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(size * 0.28),
              child: SvgPicture.asset(
                'assets/icons/logo.svg',
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        if (showText) ...[
          const SizedBox(width: 8),
          Text(
            'SwagKart',
            style: SwagTheme.display(
              size: size * 0.58,
              color: textColor ?? SwagColors.ink,
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return Pressable(onTap: onTap, child: content);
    }
    return content;
  }
}
