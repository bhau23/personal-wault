import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError('Unsupported platform: $defaultTargetPlatform');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCBVfeTfh2CqLiSjVU_bpgsjtWTPmroklc',
    appId: '1:116469235544:web:28d9e43f0f763d5a3c2f2d',
    messagingSenderId: '116469235544',
    projectId: 'wault--mobile',
    authDomain: 'wault--mobile.firebaseapp.com',
    storageBucket: 'wault--mobile.firebasestorage.app',
  );

  // Correct Android config from google-services.json
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD-8OuvfnzN8_9oqBd_tQKk9o0E_xQluUI',
    appId: '1:116469235544:android:010508f7d5000ca13c2f2d',
    messagingSenderId: '116469235544',
    projectId: 'wault--mobile',
    storageBucket: 'wault--mobile.firebasestorage.app',
  );

  // Windows uses the web config
  static const FirebaseOptions windows = web;
}
