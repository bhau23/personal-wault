import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const WaultApp());
}

class WaultApp extends StatefulWidget {
  const WaultApp({super.key});

  @override
  State<WaultApp> createState() => _WaultAppState();
}

class _WaultAppState extends State<WaultApp> {
  bool _isAuthenticated = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wault Secure',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: _isAuthenticated
          ? HomeScreen(
              onLock: () => setState(() => _isAuthenticated = false),
            )
          : AuthScreen(
              onAuthenticated: () =>
                  setState(() => _isAuthenticated = true),
            ),
    );
  }
}
