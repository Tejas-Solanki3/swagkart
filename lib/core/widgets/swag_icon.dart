import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Renders a hand-crafted SVG icon from assets/icons/`name`.svg.
///
/// All icons are drawn with `stroke="currentColor"` so [color]
/// recolors them cleanly at any size.
class SwagIcon extends StatelessWidget {
  const SwagIcon(
    this.name, {
    super.key,
    this.size = 24,
    this.color,
  });

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
    );
  }
}
