// =============================================================================
// File: lib/firebase_options.dart
// Purpose: Firebase platform configuration options mapping API keys, project IDs,
//          and storage buckets for Web, Android, iOS, and macOS platforms.
// =============================================================================

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your SwagKart Firebase project: swagkart-8f619.
///
/// Automatically determines the active host platform and returns the matching
/// configuration credentials for initializing Firebase.
class DefaultFirebaseOptions {
  /// Returns the platform-specific [FirebaseOptions] for the currently running OS.
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      default:
        return null;
    }
  }


  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDcbzOcDe8bM8FRbN1bXPQoYmYpxj-QEb8',
    appId: '1:93442249750:web:0631608014d57f29a25137',
    messagingSenderId: '93442249750',
    projectId: 'swagkart-8f619',
    authDomain: 'swagkart-8f619.firebaseapp.com',
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    measurementId: 'G-8R1D28XRK8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAG6OIKp0so9iIt5ZCYVPFNt4ZXYnL5XBw',
    appId: '1:93442249750:android:dc8e482db0c8b9f8a25137',
    messagingSenderId: '93442249750',
    projectId: 'swagkart-8f619',
    storageBucket: 'swagkart-8f619.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDcbzOcDe8bM8FRbN1bXPQoYmYpxj-QEb8',
    appId: '1:93442249750:web:0631608014d57f29a25137',
    messagingSenderId: '93442249750',
    projectId: 'swagkart-8f619',
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    iosBundleId: 'com.swagkart.swagKart',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDcbzOcDe8bM8FRbN1bXPQoYmYpxj-QEb8',
    appId: '1:93442249750:web:0631608014d57f29a25137',
    messagingSenderId: '93442249750',
    projectId: 'swagkart-8f619',
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    iosBundleId: 'com.swagkart.swagKart',
  );
}
