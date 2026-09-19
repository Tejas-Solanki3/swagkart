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


  static FirebaseOptions get web => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_WEB_API_KEY',
      defaultValue: 'YOUR_WEB_API_KEY_HERE',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_WEB_APP_ID',
      defaultValue: '1:93442249750:web:0631608014d57f29a25137',
    ),
    messagingSenderId: '93442249750',
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'swagkart-8f619',
    ),
    authDomain: 'swagkart-8f619.firebaseapp.com',
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    measurementId: 'G-8R1D28XRK8',
  );

  static FirebaseOptions get android => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_ANDROID_API_KEY',
      defaultValue: 'YOUR_ANDROID_API_KEY_HERE',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_ANDROID_APP_ID',
      defaultValue: '1:93442249750:android:dc8e482db0c8b9f8a25137',
    ),
    messagingSenderId: '93442249750',
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'swagkart-8f619',
    ),
    storageBucket: 'swagkart-8f619.firebasestorage.app',
  );

  static FirebaseOptions get ios => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_IOS_API_KEY',
      defaultValue: 'YOUR_IOS_API_KEY_HERE',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_IOS_APP_ID',
      defaultValue: '1:93442249750:web:0631608014d57f29a25137',
    ),
    messagingSenderId: '93442249750',
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'swagkart-8f619',
    ),
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    iosBundleId: 'com.swagkart.swagKart',
  );

  static FirebaseOptions get macos => FirebaseOptions(
    apiKey: const String.fromEnvironment(
      'FIREBASE_MACOS_API_KEY',
      defaultValue: 'YOUR_MACOS_API_KEY_HERE',
    ),
    appId: const String.fromEnvironment(
      'FIREBASE_MACOS_APP_ID',
      defaultValue: '1:93442249750:web:0631608014d57f29a25137',
    ),
    messagingSenderId: '93442249750',
    projectId: const String.fromEnvironment(
      'FIREBASE_PROJECT_ID',
      defaultValue: 'swagkart-8f619',
    ),
    storageBucket: 'swagkart-8f619.firebasestorage.app',
    iosBundleId: 'com.swagkart.swagKart',
  );
}

