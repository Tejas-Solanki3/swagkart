// =============================================================================
// File: lib/core/utils/responsive.dart
// Purpose: Responsive design utilities providing adaptive breakpoints (phone,
//          tablet, wide desktop), dynamic grid column counts, and padding rules.
// =============================================================================

import 'package:flutter/material.dart';

/// Screen size category breakpoints.
enum SwagSize { phone, tablet, wide }

/// Determines the current [SwagSize] based on screen width.
SwagSize swagSizeOf(BuildContext context) {
  final w = MediaQuery.sizeOf(context).width;
  if (w < 640) return SwagSize.phone;
  if (w < 1024) return SwagSize.tablet;
  return SwagSize.wide;
}

/// Product grid columns per breakpoint (2 on mobile, 3 on tablet, 4 on desktop).
int swagColumns(double width) {
  if (width < 640) return 2;
  if (width < 1024) return 3;
  return 4;
}

/// Horizontal page padding per breakpoint.
double swagPad(double width) => width < 640 ? 18 : (width < 1024 ? 28 : 36);

/// Max content width for very wide screens (prevents excessive stretching on ultra-wide).
double swagMaxWidth(double width) => width.clamp(0.0, 1180.0);

