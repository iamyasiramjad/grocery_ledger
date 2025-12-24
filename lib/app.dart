import 'package:flutter/material.dart';
import 'features/dashboard/dashboard_screen.dart';

class GroceryLedgerApp extends StatelessWidget {
  const GroceryLedgerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery Ledge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
      ),
      home: const DashboardScreen(),
    );
  }
}