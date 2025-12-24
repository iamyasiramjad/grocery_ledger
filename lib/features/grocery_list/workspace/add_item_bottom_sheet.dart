import 'package:flutter/material.dart';
import '../../../core/utils/static_items.dart';

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

  String _query = '';

  @override
  Widget build(BuildContext context) {
    final items = staticItems.where((item) {
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
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Add Item',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
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
