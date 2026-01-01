import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/utils/static_items.dart';
import '../../categories/storage/hive_user_category.dart';
import '../storage/hive_user_item.dart';

class CreateItemScreen extends StatefulWidget {
  final String? initialCategoryId;
  final HiveUserItem? existingItem;

  const CreateItemScreen({
    super.key,
    this.initialCategoryId,
    this.existingItem,
  });

  @override
  State<CreateItemScreen> createState() => _CreateItemScreenState();
}

class _CreateItemScreenState extends State<CreateItemScreen> {
  late final TextEditingController _nameController;
  final _nameFocusNode = FocusNode();
  
  String? _selectedCategoryName; // The display name
  String? _selectedCategoryId;   // The Hive ID (or name for static)

  List<_CategoryOption> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.existingItem?.name ?? '');
    _nameFocusNode.requestFocus();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    // 1. Get static categories
    final staticCats = staticItems.map((e) => e.category).toSet().map((name) => _CategoryOption(id: name, name: name, isStatic: true));

    // 2. Get user categories
    final categoryBox = await Hive.openBox<HiveUserCategory>('user_categories');
    final userCats = categoryBox.values.map((cat) => _CategoryOption(id: cat.id, name: cat.name, isStatic: false));

    // 3. Merge and sort
    final merged = [...staticCats, ...userCats];
    merged.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

    if (mounted) {
      setState(() {
        _categories = merged;
        _isLoading = false;

        // Pre-select category if provided or existing
        final targetCatId = widget.existingItem?.categoryId ?? widget.initialCategoryId;
        if (targetCatId != null) {
          try {
            final initial = merged.firstWhere((c) => c.id == targetCatId);
            _selectedCategoryId = initial.id;
            _selectedCategoryName = initial.name;
          } catch (_) {}
        }
      });
    }
  }

  Future<void> _saveItem() async {
    final name = _nameController.text.trim();

    // 3️⃣ VALIDATION RULES
    if (name.isEmpty) {
      _showError('Item name must not be empty');
      return;
    }

    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }

    // Check uniqueness within category
    final isDuplicate = await _checkIfDuplicate(name, _selectedCategoryName!);
    if (isDuplicate) {
      _showError('Item "$name" already exists in category "${_selectedCategoryName}"');
      return;
    }

    // 4️⃣ SAVE LOGIC
    if (widget.existingItem != null) {
      // Update existing
      widget.existingItem!.name = name;
      widget.existingItem!.categoryId = _selectedCategoryId!;
      await widget.existingItem!.save();
    } else {
      // Create new
      final itemBox = await Hive.openBox<HiveUserItem>('user_items');
      final id = DateTime.now().millisecondsSinceEpoch.toString();
      final newItem = HiveUserItem(id: id, name: name, categoryId: _selectedCategoryId!);
      await itemBox.put(id, newItem);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<bool> _checkIfDuplicate(String name, String categoryName) async {
    final lowerName = name.toLowerCase();
    final lowerCat = categoryName.toLowerCase();

    // Check static items
    final staticMatch = staticItems.any((item) => 
      item.name.toLowerCase() == lowerName && 
      item.category.toLowerCase() == lowerCat);
    if (staticMatch) return true;

    // Check user items
    final itemBox = await Hive.openBox<HiveUserItem>('user_items');
    final categoryBox = await Hive.openBox<HiveUserCategory>('user_categories');
    
    // Create lookup for user items
    for (final item in itemBox.values) {
      // If editing, skip the current item
      if (widget.existingItem != null && item.id == widget.existingItem!.id) {
        continue;
      }

      if (item.name.toLowerCase() == lowerName) {
        // Find category name for this item
        String? itemCatName;
        final userCat = categoryBox.values.firstWhere((c) => c.id == item.categoryId, orElse: () => HiveUserCategory(id: '', name: ''));
        
        if (userCat.id.isNotEmpty) {
          itemCatName = userCat.name;
        } else {
          itemCatName = item.categoryId; 
        }

        if (itemCatName.toLowerCase() == lowerCat) return true;
      }
    }

    return false;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingItem != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Item' : 'Add Item')),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _nameController,
                  focusNode: _nameFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  items: _categories.map((cat) {
                    return DropdownMenuItem(
                      value: cat.id,
                      child: Text('${cat.name}${cat.isStatic ? "" : " (User)"}'),
                    );
                  }).toList(),
                  onChanged: (id) {
                    final selected = _categories.firstWhere((c) => c.id == id);
                    setState(() {
                      _selectedCategoryId = id;
                      _selectedCategoryName = selected.name;
                    });
                  },
                ),
                const spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveItem,
                    child: Text(isEditing ? 'Save Changes' : 'Save Item'),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}

class _CategoryOption {
  final String id;
  final String name;
  final bool isStatic;
  _CategoryOption({required this.id, required this.name, required this.isStatic});
}

class spacer extends StatelessWidget {
  const spacer({super.key});
  @override
  Widget build(BuildContext context) => const Expanded(child: SizedBox());
}
