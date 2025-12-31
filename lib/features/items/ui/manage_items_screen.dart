import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../categories/storage/hive_user_category.dart';
import '../storage/hive_user_item.dart';
import 'create_item_screen.dart';

class ManageItemsScreen extends StatefulWidget {
  const ManageItemsScreen({super.key});

  @override
  State<ManageItemsScreen> createState() => _ManageItemsScreenState();
}

class _ManageItemsScreenState extends State<ManageItemsScreen> {
  Future<void>? _initFuture;
  late Box<HiveUserItem> _itemBox;
  late Box<HiveUserCategory> _categoryBox;

  @override
  void initState() {
    super.initState();
    _initFuture = _initBoxes();
  }

  Future<void> _initBoxes() async {
    _itemBox = await Hive.openBox<HiveUserItem>('user_items');
    _categoryBox = await Hive.openBox<HiveUserCategory>('user_categories');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Manage Items'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CreateItemScreen()),
                  );
                },
              ),
            ],
          ),
          body: ValueListenableBuilder(
            valueListenable: _itemBox.listenable(),
            builder: (context, box, _) {
              final items = _itemBox.values.toList();
              
              if (items.isEmpty) {
                return const Center(child: Text('No custom items yet'));
              }

              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  // Resolve category name
                  final userCat = _categoryBox.values.firstWhere(
                    (c) => c.id == item.categoryId, 
                    orElse: () => HiveUserCategory(id: '', name: item.categoryId)
                  );
                  
                  return ListTile(
                    title: Text(item.name),
                    subtitle: Text('Category: ${userCat.name}'),
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

// Renamed helper class to avoid AppBar name conflict if any
class app_bar extends AppBar {
  app_bar({super.key, required super.title, super.actions});
}
