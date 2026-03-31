import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';
import 'services/encryption_service.dart';
import 'screens/login_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Enable offline persistence so the app works without internet
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const WaultApp());
}

class WaultApp extends StatefulWidget {
  const WaultApp({super.key});

  @override
  State<WaultApp> createState() => _WaultAppState();
}

class _WaultAppState extends State<WaultApp> {
  final _encryption = EncryptionService();

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wault Secure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // Still checking auth state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Not logged in → show Firebase login screen
          if (snapshot.data == null) {
            return const LoginScreen();
          }

          // Logged in but encryption not initialized → show master password
          if (!_encryption.isInitialized) {
            return AuthScreen(onAuthenticated: _refresh);
          }

          // Fully authenticated → show vault
          return HomeScreen(onLock: _refresh);
        },
      ),
    );
  }
}
