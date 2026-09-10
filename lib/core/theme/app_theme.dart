import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Custom springy page transition used on Android.
class SwagPageTransitions extends PageTransitionsBuilder {
  const SwagPageTransitions();

  @override
  Duration get transitionDuration => const Duration(milliseconds: 340);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 240);

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
        offset: Offset(0, 26 * (1 - t)),
        child: Transform.scale(
          scale: 0.955 + 0.045 * t,
          child: child,
        ),
      ),
    );
  }
}

class SwagTheme {
  SwagTheme._();

  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: SwagColors.cream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: SwagColors.tangerine,
        surface: SwagColors.paper,
        primary: SwagColors.tangerine,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: SwagColors.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: SwagColors.paper,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
    );
  }

  /// Baloo 2 — the playful display face.
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
