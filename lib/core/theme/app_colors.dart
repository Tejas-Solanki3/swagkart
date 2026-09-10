import 'package:flutter/material.dart';

/// SwagKart palette — warm cream base with a candy-accent set.
class SwagColors {
  SwagColors._();

  // Base
  static const Color cream = Color(0xFFF8F3EA);
  static const Color paper = Color(0xFFFFFFFF);
  static const Color sand = Color(0xFFEDE3D2);
  static const Color sandSoft = Color(0xFFF3ECDF);

  // Text
  static const Color ink = Color(0xFF221A13);
  static const Color inkSoft = Color(0xFF6E6254);
  static const Color inkFaint = Color(0xFFAB9E8D);

  // Accents
  static const Color tangerine = Color(0xFFFF6B35);
  static const Color tangerineDeep = Color(0xFFE8531F);
  static const Color tangerineSoft = Color(0xFFFFE8DE);
  static const Color pistachio = Color(0xFF8FCF9B);
  static const Color pistachioSoft = Color(0xFFE3F2E4);
  static const Color butter = Color(0xFFFFD166);
  static const Color butterSoft = Color(0xFFFFF3D6);
  static const Color sky = Color(0xFF79C4E0);
  static const Color skySoft = Color(0xFFE1F2FA);
  static const Color lilac = Color(0xFFC4B0F0);
  static const Color lilacSoft = Color(0xFFF1ECFB);
  static const Color blush = Color(0xFFFF9E9E);
  static const Color blushSoft = Color(0xFFFFE7E3);

  // Feedback
  static const Color success = Color(0xFF2E9E5B);
  static const Color successSoft = Color(0xFFDFF4E7);
  static const Color danger = Color(0xFFE05542);

  static const List<Color> candy = <Color>[
    tangerine,
    butter,
    pistachio,
    sky,
    lilac,
    blush,
  ];
}

/// Shared demo constants.
const double kFreeShippingThreshold = 999;
const double kFlatShippingFee = 79;
