import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

/// THESE ARE PLACEHOLDER KEYS.
/// You MUST replace these with the real keys from console.firebase.google.com!
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError('iOS placeholder not defined');
      case TargetPlatform.macOS:
        throw UnsupportedError('macOS placeholder not defined');
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError('Linux placeholder not defined');
      default:
        throw UnsupportedError('Unsupported platform');
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCBVfeTfh2CqLiSjVU_bpgsjtWTPmroklc',
    appId: '1:116469235544:android:28d9e43f0f763d5a3c2f2d', // Adapted from web
    messagingSenderId: '116469235544',
    projectId: 'wault--mobile',
    storageBucket: 'wault--mobile.firebasestorage.app',
  );

  static const FirebaseOptions windows = web;
}
