// =============================================================================
// File: lib/core/theme/app_colors.dart
// Purpose: Defines the centralized color palette and ecommerce business thresholds
//          used across the entire SwagKart mobile and web application.
// =============================================================================

import 'package:flutter/material.dart';

/// SwagKart palette — a premium soft-pastel system:
/// misty lavender canvas, white surfaces, near-black ink,
/// a muted coral signature accent and a calm pastel set.
class SwagColors {
  SwagColors._();

  // Canvas & surfaces
  /// Primary app canvas background tone (misty light grey/lavender)
  static const Color canvas = Color(0xFFF1F0F6);
  /// Pure white background for card containers and elevated dialogs
  static const Color surface = Color(0xFFFFFFFF);
  /// Subtle secondary surface tone for chip backgrounds and search bars
  static const Color surfaceMist = Color(0xFFE9E7F2);
  /// Fine border line divider color for crisp, modern boundaries
  static const Color line = Color(0xFFE3E1ED);
  /// Warm photo mat background tone underneath transparent product PNGs
  static const Color photoMat = Color(0xFFF8F3EA);


  // Text
  static const Color ink = Color(0xFF1C1B24);
  static const Color inkSoft = Color(0xFF6F6D80);
  static const Color inkFaint = Color(0xFFA9A7BA);

  // Signature accent — muted coral
  static const Color accent = Color(0xFFE5876C);
  static const Color accentDeep = Color(0xFFCE6547);
  static const Color accentSoft = Color(0xFFFBE9E1);

  // Soft pastel set
  static const Color lavender = Color(0xFFA79BD8);
  static const Color lavenderSoft = Color(0xFFE8E4F5);
  static const Color mist = Color(0xFF85AEDD);
  static const Color mistSoft = Color(0xFFE0EAF6);
  static const Color blush = Color(0xFFD2848E);
  static const Color blushSoft = Color(0xFFF9E4E8);
  static const Color butter = Color(0xFFD2A94F);
  static const Color butterSoft = Color(0xFFF8F0D9);
  static const Color mint = Color(0xFF79B28E);
  static const Color mintSoft = Color(0xFFE1F0E6);
  static const Color peach = Color(0xFFDE9A6C);
  static const Color peachSoft = Color(0xFFFBEADD);
  static const Color green = Color(0xFF34A853);

  // Deep text tones for readable labels on pastel chips
  static const Color lavenderDeep = Color(0xFF6F5FB5);
  static const Color mistDeep = Color(0xFF4A78AC);
  static const Color blushDeep = Color(0xFFB05A68);
  static const Color butterDeep = Color(0xFFA8842F);
  static const Color mintDeep = Color(0xFF417A58);
  static const Color peachDeep = Color(0xFFB0703F);

  // Feedback
  static const Color success = Color(0xFF4E9C72);
  static const Color successSoft = Color(0xFFE1F0E6);
  static const Color danger = Color(0xFFC9553F);
  static const Color dangerSoft = Color(0xFFFBE9E1);

  static const List<Color> pastel = <Color>[
    lavender,
    mist,
    blush,
    butter,
    mint,
    peach,
  ];
}

/// Shared demo constants.
const double kFreeShippingThreshold = 999;
const double kFlatShippingFee = 79;
