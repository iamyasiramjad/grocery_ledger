import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/utils/static_items.dart';
import '../storage/hive_user_category.dart';

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto-focus enabled as per requirement 2
    _nameFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    final name = _nameController.text.trim();

    // 3️⃣ VALIDATION RULES
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name must not be empty')),
      );
      return;
    }

    // Load static categories for validation
    final staticCategories = staticItems.map((item) => item.category.toLowerCase()).toSet();
    
    // Load existing user categories
    final categoryBox = await Hive.openBox<HiveUserCategory>('user_categories');
    final existingUserCategories = categoryBox.values.map((cat) => cat.name.toLowerCase()).toSet();

    if (staticCategories.contains(name.toLowerCase()) || 
        existingUserCategories.contains(name.toLowerCase())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category name already exists')),
      );
      return;
    }

    // 4️⃣ SAVE LOGIC
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final newCategory = HiveUserCategory(id: id, name: name);
    
    await categoryBox.put(id, newCategory);

    if (mounted) {
      Navigator.pop(context, true); // Return true to indicate refresh needed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              focusNode: _nameFocusNode,
              decoration: const InputDecoration(
                labelText: 'Category name',
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _saveCategory(),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveCategory,
                child: const Text('Save Category'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
