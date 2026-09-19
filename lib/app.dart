// =============================================================================
// File: lib/app.dart
// Purpose: Root MaterialApp widget configuring the global theme, debug flags,
//          and setting the initial entry point to SplashScreen.
// =============================================================================

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/splash/splash_screen.dart';

/// The root presentation widget of SwagKart.
///
/// Configures:
/// - App title ('SwagKart')
/// - Disabling debug banner
/// - Custom light theme with brand colors and typography ([SwagTheme.light])
/// - Splash screen entry route ([SplashScreen])
class SwagKartMaterialApp extends StatelessWidget {
  const SwagKartMaterialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwagKart',
      debugShowCheckedModeBanner: false,
      theme: SwagTheme.light(),
      home: const SplashScreen(),
    );
  }
}

