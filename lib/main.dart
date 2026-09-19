// =============================================================================
// File: lib/main.dart
// Purpose: Application entry point initializing Flutter engine bindings,
//          Firebase services, platform UI overlays, and state injection.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'services/firebase_service.dart';
import 'state/app_store.dart';

/// App main entry point.
///
/// 1. Ensures Flutter widget bindings are initialized before async calls.
/// 2. Initializes Firebase (with offline / mock fallback safety).
/// 3. Configures system status bar and navigation bar colors/icons.
/// 4. Boots the root widget [SwagKartApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseService.initialize();

  // Configure Android / iOS system bar overlay styles to match pastel canvas
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8F3EA),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SwagKartApp());
}

/// Root application widget that binds the global state ([SwagAppStore])
/// to the entire widget tree via [ChangeNotifierProvider].
class SwagKartApp extends StatelessWidget {
  const SwagKartApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Provide SwagAppStore at the top level so any screen can access cart,
    // wishlist, products, and auth state.
    return ChangeNotifierProvider<SwagAppStore>(
      create: (_) => SwagAppStore(),
      child: const SwagKartMaterialApp(),
    );
  }
}

