import 'package:flutter/material.dart';

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
      home: home,
    );
  }
}