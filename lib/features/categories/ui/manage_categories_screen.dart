import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/hive_user_category.dart';
import 'create_category_screen.dart';
import '../../items/ui/manage_items_screen.dart';
import '../../items/ui/create_item_screen.dart';
import '../../items/storage/hive_user_item.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  Future<Box<HiveUserCategory>>? _openBoxFuture;

  @override
  void initState() {
    super.initState();
    _openBoxFuture = Hive.openBox<HiveUserCategory>('user_categories');
  }

  /// 3️⃣ DELETE CATEGORY LOGIC
  Future<void> _deleteCategory(HiveUserCategory category) async {
    // 1. Check if any user items exist with this categoryId
    final itemBox = await Hive.openBox<HiveUserItem>('user_items');
    final hasItems = itemBox.values.any((item) => item.categoryId == category.id);

    if (!mounted) return;

    if (hasItems) {
      // Show error dialog: items exist
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Cannot delete category'),
          content: const Text('This category has items. Please delete or move them first.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    // 2. Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete category?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await category.delete();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Category deleted')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Box<HiveUserCategory>>(
      future: _openBoxFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Categories'),
            actions: [
              IconButton(
                icon: const Icon(Icons.inventory_2_outlined),
                tooltip: 'Manage Items',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ManageItemsScreen()),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateCategoryScreen()),
                  );
                },
              ),
            ],
          ),
          body: ValueListenableBuilder<Box<HiveUserCategory>>(
            valueListenable: snapshot.data!.listenable(),
            builder: (context, box, _) {
              final categories = box.values.toList();

              if (categories.isEmpty) {
                return const Center(
                  child: Text('No custom categories yet'),
                );
              }

              return ListView.builder(
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return ListTile(
                    title: Text(category.name),
                    subtitle: Text('ID: ${category.id}'),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateCategoryScreen(
                                existingCategory: category,
                              ),
                            ),
                          );
                        } else if (value == 'delete') {
                          _deleteCategory(category);
                        } else if (value == 'add_item') {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CreateItemScreen(
                                initialCategoryId: category.id,
                              ),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'add_item',
                          child: Row(
                            children: [
                              Icon(Icons.add_shopping_cart, size: 20),
                              SizedBox(width: 8),
                              Text('Add Item'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
