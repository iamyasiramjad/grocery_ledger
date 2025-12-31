import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../storage/hive_user_category.dart';
import 'create_category_screen.dart';
import '../../items/ui/create_item_screen.dart';

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
                    trailing: IconButton(
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Add item to this category',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CreateItemScreen(
                              initialCategoryId: category.id,
                            ),
                          ),
                        );
                      },
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
