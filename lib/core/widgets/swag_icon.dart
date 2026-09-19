// =============================================================================
// File: lib/core/widgets/swag_icon.dart
// Purpose: Hand-crafted SVG asset icon renderer with dynamic color filtering
//          and automated Material icon fallbacks when SVGs are missing.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a hand-crafted SVG icon from assets/icons/`name`.svg.
///
/// All icons are drawn with `stroke="currentColor"` so [color]
/// recolors them cleanly at any size.
///
/// If an SVG asset fails to load, gracefully falls back to a matching [IconData].
class SwagIcon extends StatelessWidget {
  const SwagIcon(this.name, {super.key, this.size = 24, this.color});

  final String name;
  final double size;
  final Color? color;


  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: size,
      height: size,
      colorFilter: color == null
          ? null
          : ColorFilter.mode(color!, BlendMode.srcIn),
      errorBuilder: (context, error, stackTrace) => SizedBox(
        width: size,
        height: size,
        child: Center(
          child: Icon(_fallbackIcon(name), size: size * 0.85, color: color),
        ),
      ),
    );
  }

  static IconData _fallbackIcon(String name) {
    switch (name) {
      case 'mail':
        return Icons.mail_outline_rounded;
      case 'phone':
        return Icons.phone_outlined;
      case 'alert':
        return Icons.error_outline_rounded;
      case 'lock':
        return Icons.lock_outline_rounded;
      case 'user':
      case 'user-filled':
        return Icons.person_outline_rounded;
      case 'bag':
      case 'bag-filled':
        return Icons.shopping_bag_outlined;
      case 'heart':
      case 'heart-filled':
        return Icons.favorite_border_rounded;
      case 'search':
        return Icons.search_rounded;
      case 'arrow-left':
        return Icons.arrow_back_rounded;
      case 'arrow-right':
        return Icons.arrow_forward_rounded;
      case 'check':
        return Icons.check_rounded;
      case 'close':
        return Icons.close_rounded;
      default:
        return Icons.circle_outlined;
    }
  }
}
