import 'package:flutter/material.dart';

class CreateGroceryListScreen extends StatelessWidget {
  const CreateGroceryListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Grocery List'),
      ),
      body: const Center(
        child: Text(
          'Create Grocery List Screen',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
