import 'package:flutter/material.dart';
import '../grocery_list/create_grocery_list_screen.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery Ledger'),
      ),
      body: const Center(
        child: Text(
          'Dashboard',
          style: TextStyle(fontSize: 18),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateGroceryListScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
