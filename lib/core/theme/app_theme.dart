import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Soft, premium page transition: gentle fade + lift + settle.
class SwagPageTransitions extends PageTransitionsBuilder {
  const SwagPageTransitions();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 320);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 220);

  @override
  Widget buildTransitions<T>(
    Route<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final t = Curves.easeOutCubic.transform(animation.value);
    return FadeTransition(
      opacity: animation,
      child: Transform.translate(
        offset: Offset(0, 18 * (1 - t)),
        child: Transform.scale(
          scale: 0.97 + 0.03 * t,
          child: child,
        ),
      ),
    );
  }
}

class SwagTheme {
  SwagTheme._();

  /// Shared soft shadow used by premium cards.
  static const BoxShadow cardShadow = BoxShadow(
    color: Color(0x14585470),
    blurRadius: 22,
    offset: Offset(0, 10),
    spreadRadius: -4,
  );

  static BoxDecoration cardDecoration({
    double radius = 24,
    Color color = SwagColors.surface,
    bool shadow = true,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: SwagColors.line),
      boxShadow: shadow ? [cardShadow] : null,
    );
  }

  /// Circular soft icon-button background (reference-style round buttons).
  static BoxDecoration iconButtonDecoration({
    Color color = SwagColors.surfaceMist,
    double size = 44,
  }) {
    return BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      boxShadow: const [
        BoxShadow(
          color: Color(0x0F585470),
          blurRadius: 10,
          offset: Offset(0, 4),
        ),
      ],
    );
  }

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SwagColors.canvas,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SwagColors.accent,
        surface: SwagColors.surface,
        primary: SwagColors.ink,
        onPrimary: Colors.white,
      ),
    );

    final textTheme = base.textTheme.apply(
      fontFamily: 'Inter',
      bodyColor: SwagColors.ink,
      displayColor: SwagColors.ink,
    );

    return base.copyWith(
      textTheme: textTheme,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SwagPageTransitions(),
          TargetPlatform.fuchsia: SwagPageTransitions(),
        },
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: SwagColors.ink,
        contentTextStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SwagColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SwagColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  /// Baloo 2 — the rounded display face.
  static TextStyle display({
    double size = 20,
    FontWeight weight = FontWeight.w800,
    Color color = SwagColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Baloo2',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.15,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Inter — the workhorse body face.
  static TextStyle body({
    double size = 14,
    FontWeight weight = FontWeight.w400,
    Color color = SwagColors.ink,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: 'Inter',
      fontSize: size,
      fontWeight: weight,
      color: color,
      height: height ?? 1.4,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }
}
