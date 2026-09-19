// =============================================================================
// File: lib/core/nav.dart
// Purpose: Centralized navigation utility providing clean routing primitives
//          (push, pushReplacement, pop, popToRoot) across the application.
// =============================================================================

import 'package:flutter/material.dart';

/// Playful route transitions shared across the app.
///
/// In modern Flutter the transition comes from the [PageTransitionsTheme]
/// in the app theme (see [SwagTheme.light]), so navigation helpers stay simple.
class SwagNav {
  SwagNav._();

  /// Pushes a new route onto the navigation stack.
  static void push(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).push(MaterialPageRoute(builder: builder));
  }

  /// Replaces the current route with a new route.
  static void pushReplacement(
    BuildContext context,
    Widget Function(BuildContext) builder,
  ) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: builder));
  }

  /// Pops the topmost route off the navigator.
  static void pop(BuildContext context) => Navigator.of(context).pop();

  /// Pops all routes until reaching the root route (e.g. returning to the 5-tab shell).
  static void popToRoot(BuildContext context) =>
      Navigator.of(context).popUntil((route) => route.isFirst);
}

