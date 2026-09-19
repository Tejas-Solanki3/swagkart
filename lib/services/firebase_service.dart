// =============================================================================
// File: lib/services/firebase_service.dart
// Purpose: Firebase bootstrap service ensuring safe initialization across Web,
//          Android, iOS, and macOS platforms without breaking widget tests.
// =============================================================================

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

/// Centralized service responsible for initializing the Firebase app instance.
class FirebaseService {
  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  /// Initializes Firebase safely with try/catch to ensure widget tests and
  /// local development run smoothly even before remote credentials are configured.
  static Future<void> initialize() async {

    try {
      if (Firebase.apps.isNotEmpty) {
        _initialized = true;
        return;
      }

      final options = DefaultFirebaseOptions.currentPlatform;
      // If valid credentials are provided in firebase_options.dart or via environment
      if (options != null &&
          options.apiKey.isNotEmpty &&
          !options.apiKey.contains('Placeholder') &&
          !options.apiKey.startsWith('YOUR_')) {
        await Firebase.initializeApp(options: options);
        _initialized = true;
        if (kDebugMode) {
          print('✅ Connected to Firebase project: ${options.projectId}');
        }
      } else if (!kIsWeb) {
        // Native Android / iOS platforms with google-services.json
        await Firebase.initializeApp();
        _initialized = true;
        if (kDebugMode) {
          print('✅ Firebase initialized from native configuration');
        }
      } else {
        _initialized = false;
        if (kDebugMode) {
          print(
            'ℹ️ Firebase running in local fallback mode (configure credentials in lib/firebase_options.dart)',
          );
        }
      }
    } catch (e) {
      _initialized = false;
      if (kDebugMode) {
        print('ℹ️ Firebase running in local fallback mode: $e');
      }
    }
  }
}
