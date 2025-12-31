import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/utils/static_items.dart';
import '../../categories/storage/hive_user_category.dart';
import '../../items/storage/hive_user_item.dart';
import '../../items/presentation/pages/create_item_screen.dart';

class AddItemBottomSheet extends StatefulWidget {
  final void Function(List<StaticItem>) onItemsSelected;

  const AddItemBottomSheet({
    super.key,
    required this.onItemsSelected,
  });

  @override
  State<AddItemBottomSheet> createState() => _AddItemBottomSheetState();
}

/* ============================================================
   STATE CLASS
   Everything below lives INSIDE the bottom sheet
   ============================================================ */

class _AddItemBottomSheetState extends State<AddItemBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

  final Set<StaticItem> _selectedItems = {};
  List<StaticItem> _allAvailableItems = [];
  bool _isLoading = true;

  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadAllItems();
  }

  Future<void> _loadAllItems() async {
    // 1️⃣ LOAD USER DATA
    final categoryBox = await Hive.openBox<HiveUserCategory>('user_categories');
    final itemBox = await Hive.openBox<HiveUserItem>('user_items');

    // Create a lookup map for category names
    final Map<String, String> categoryNames = {
      for (final cat in categoryBox.values) cat.id: cat.name,
    };

    // Also add static categories to the lookup (where ID == Name)
    final staticCategoryNames = staticItems.map((e) => e.category).toSet();
    for (final name in staticCategoryNames) {
      if (!categoryNames.containsKey(name)) {
        categoryNames[name] = name;
      }
    }

    // 2️⃣ NORMALIZE DATA
    final userNormalized = itemBox.values
        .map((hiveItem) {
          final categoryName = categoryNames[hiveItem.categoryId];
          if (categoryName == null) return null; // Skip if invalid category

          return StaticItem(hiveItem.name, categoryName);
        })
        .whereType<StaticItem>()
        .toList();

    // 3️⃣ MERGE LOGIC
    // Use a map to handle overrides and duplicates
    // Key is name to ensure "names clash" override logic
    final Map<String, StaticItem> mergedItems = {};

    // First add static items
    for (final item in staticItems) {
      mergedItems[item.name] = item;
    }

    // Then add user items (overriding static items if names clash)
    for (final item in userNormalized) {
      mergedItems[item.name] = item;
    }

    if (mounted) {
      setState(() {
        _allAvailableItems = mergedItems.values.toList();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _allAvailableItems.where((item) {
      return item.name.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildSearchField(),
          Expanded(child: _buildItemList(items)),
          _buildConfirmButton(),
        ],
      ),
    );
  }

  /* ===================== UI PARTS ===================== */

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Add Item',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add New Item'),
            onPressed: () async {
              // Navigate to item creation
              final created = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => CreateItemScreen()),
              );
              // If an item was created, reload the list to show it
              if (created == true) {
                _loadAllItems();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: 'Search item',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (value) {
          setState(() {
            _query = value;
          });
        },
      ),
    );
  }

  Widget _buildItemList(List<StaticItem> items) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = _selectedItems.contains(item);

        return ListTile(
          title: Text(item.name),
          subtitle: Text(item.category),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : null,
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedItems.remove(item);
              } else {
                _selectedItems.add(item);
              }
            });
          },
        );
      },
    );
  }

  Widget _buildConfirmButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _selectedItems.isEmpty
            ? null
            : () {
                widget.onItemsSelected(_selectedItems.toList());
                Navigator.pop(context);
              },
        child: Text(
          'Add ${_selectedItems.length} item${_selectedItems.length > 1 ? 's' : ''}',
        ),
      ),
    );
  }
}
