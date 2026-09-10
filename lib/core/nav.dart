import 'package:flutter/material.dart';

/// Playful route transitions shared across the app.
///
/// In modern Flutter the transition comes from the [PageTransitionsTheme]
/// in the app theme (see SwagTheme), so navigation helpers stay simple.
class SwagNav {
  SwagNav._();

  static void push(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: builder),
    );
  }

  static void pushReplacement(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: builder),
    );
  }

  static void pop(BuildContext context) => Navigator.of(context).pop();

  /// Pops everything back to the root route (the tab shell).
  static void popToRoot(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);
}
