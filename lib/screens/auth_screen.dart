import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;
  const AuthScreen({super.key, required this.onAuthenticated});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _auth = AuthService();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isSetup = false;
  bool _isLoading = true;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final setup = await _auth.isSetup();
    setState(() {
      _isSetup = !setup;
      _isLoading = false;
    });
  }

  Future<void> _submit() async {
    final password = _passwordController.text.trim();
    if (password.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters');
      return;
    }

    setState(() {
      _error = null;
      _isLoading = true;
    });

    if (_isSetup) {
      if (password != _confirmController.text.trim()) {
        setState(() {
          _error = 'Passwords do not match';
          _isLoading = false;
        });
        return;
      }
      await _auth.setup(password);
      widget.onAuthenticated();
    } else {
      final valid = await _auth.verify(password);
      if (valid) {
        widget.onAuthenticated();
      } else {
        setState(() {
          _error = 'Incorrect master password';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_rounded,
                  size: 56,
                  color: theme.colorScheme.primary,
                ),
              )
                  .animate()
                  .fadeIn(duration: 600.ms)
                  .scale(begin: const Offset(0.8, 0.8)),
              const SizedBox(height: 24),
              Text(
                'Wault Secure',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 8),
              Text(
                _isSetup
                    ? 'Create a master password to get started'
                    : 'Enter your master password to unlock',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white54,
                ),
                textAlign: TextAlign.center,
              ).animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 40),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                autofocus: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  labelText: 'Master Password',
                  prefixIcon: const Icon(Icons.key_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
              if (_isSetup) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.key_rounded),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
              ],
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isSetup ? 'Create Vault' : 'Unlock'),
                ),
              ).animate().fadeIn(delay: 600.ms),
            ],
          ),
        ),
      ),
    );
  }
}
