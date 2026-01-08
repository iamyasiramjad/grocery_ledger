import 'package:flutter/material.dart';
import 'core/auth/app_lock_gate.dart';

/// Root application widget for Grocery Ledger.
///
/// The initial [home] screen is determined BEFORE this widget is created,
/// in main.dart, to ensure no flicker or intermediate screens.
class GroceryLedgerApp extends StatelessWidget {
  /// The initial screen to display (OnboardingScreen or DashboardScreen).
  final Widget home;

  const GroceryLedgerApp({super.key, required this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      // AppLockGate is wrapped around the Navigator using the builder property.
      // This ensures it stays above all routes and persists throughout the app lifecycle.
      builder: (context, child) => AppLockGate(child: child!),
      home: home,
    );
  }
}