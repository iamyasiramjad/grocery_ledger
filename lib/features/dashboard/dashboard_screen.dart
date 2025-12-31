import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../grocery_list/storage/hive_grocery_list.dart';
import '../grocery_list/workspace/grocery_list_workspace_screen.dart';
import '../grocery_list/create_grocery_list_screen.dart';
import '../categories/ui/manage_categories_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Box<HiveGroceryList>? _groceryListBox;

  @override
  void initState() {
    super.initState();
    _openBox();
  }

  Future<void> _openBox() async {
    _groceryListBox = await Hive.openBox<HiveGroceryList>('grocery_lists');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // ⏳ Loading
    if (_groceryListBox == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Grocery Lists'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final lists = _groceryListBox!.values.toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Grocery Lists'),
        actions: [
          IconButton(
            icon: const Icon(Icons.category),
            tooltip: 'Manage Categories',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ManageCategoriesScreen()),
              );
            },
          ),
        ],
      ),
      body: lists.isEmpty
          ? const Center(
              child: Text('No grocery lists yet'),
            )
          : ListView.builder(
              itemCount: lists.length,
              itemBuilder: (context, index) {
                final list = lists[index];

                final subtotal = list.entries.fold<double>(
                  0.0,
                  (sum, entry) {
                    if (entry.unitPrice != null) {
                      return sum + (entry.unitPrice! * entry.quantity);
                    }
                    if (entry.totalPrice != null) {
                      return sum + entry.totalPrice!;
                    }
                    return sum;
                  },
                );

                final total = subtotal + list.adjustment;

                return ListTile(
                  title: Text(list.name),
                  subtitle: Text(
                    'Date: ${list.date.year}-'
                    '${list.date.month.toString().padLeft(2, '0')}-'
                    '${list.date.day.toString().padLeft(2, '0')}',
                  ),
                  trailing: Text(
                    'Rs. ${total.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GroceryListWorkspaceScreen(
                          listName: list.name,
                          shoppingDate: list.date,
                          importFromPrevious: false,
                          existingList: list,
                          existingListKey: list.key, // 👈 PASS THE UNIQUE KEY
                        ),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),

      // ➕ New list
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CreateGroceryListScreen(),
            ),
          ).then((_) => setState(() {}));
        },
      ),
    );
  }
}
