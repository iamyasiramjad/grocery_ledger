import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:grocery_ledger/features/auth/login_screen.dart';
import 'auth_service.dart';

class AuthGate extends StatelessWidget {
  final Widget authenticated;
  
  const AuthGate({
    super.key,
    required this.authenticated,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        final session = snapshot.data?.session;
        final isLoggedIn = session != null || AuthService.instance.isLoggedIn;

        if (isLoggedIn) {
          return authenticated;
        }

        return const LoginScreen();
      },
    );
  }
}
