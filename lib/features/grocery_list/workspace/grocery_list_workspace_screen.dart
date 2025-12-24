import 'package:flutter/material.dart';

class GroceryListWorkspaceScreen extends StatelessWidget {
  final String listName;
  final DateTime shoppingDate;
  final bool importFromPrevious;

  const GroceryListWorkspaceScreen({
    super.key,
    required this.listName,
    required this.shoppingDate,
    required this.importFromPrevious,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(listName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Shopping date: ${shoppingDate.year}-${shoppingDate.month.toString().padLeft(2, '0')}-${shoppingDate.day.toString().padLeft(2, '0')}',
            ),
            const SizedBox(height: 8),
            Text(
              importFromPrevious
                  ? 'Started by importing previous month'
                  : 'Started from scratch',
              style: const TextStyle(fontStyle: FontStyle.italic),
            ),
            const Divider(height: 32),
            const Text(
              'Items will appear here',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
