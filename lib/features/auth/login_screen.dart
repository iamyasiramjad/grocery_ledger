import 'package:flutter/material.dart';
import '../../core/auth/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _loading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() {
      _loading = true;
    });

    try {
      await AuthService.instance.signInWithGoogle();
      // Supabase will handle session persistence automatically
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Grocery Ledger',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loading ? null : _handleGoogleLogin,
                icon: const Icon(Icons.login),
                label: _loading
                    ? const Text('Signing in...')
                    : const Text('Continue with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
