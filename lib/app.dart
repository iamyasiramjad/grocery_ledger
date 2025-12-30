import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';

class GroceryLedgerApp extends StatelessWidget {
  const GroceryLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Ledger',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: OnboardingScreen(
        onAddSampleData: () {
          // TODO: Add sample data logic and navigate to DashboardScreen
        },
        onStartEmpty: () {
          // TODO: Navigate to DashboardScreen
        },
      ),
    );
  }
}