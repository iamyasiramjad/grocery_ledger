import 'package:flutter/material.dart';
import '../../../core/utils/static_items.dart';
import 'add_item_bottom_sheet.dart';
import '../models/list_entry.dart';

class GroceryListWorkspaceScreen extends StatefulWidget {
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
  State<GroceryListWorkspaceScreen> createState() =>
      _GroceryListWorkspaceScreenState();
}

/* ============================================================
   EVERYTHING BELOW THIS LINE IS THE "STATE CLASS"
   THIS IS WHERE YOU PUT LOGIC + UI
   ============================================================ */

class _GroceryListWorkspaceScreenState
    extends State<GroceryListWorkspaceScreen> {

  // 🧠 STATE (in-memory)
  final List<ListEntry> _entries = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listName),
      ),
      body: Column(
        children: [
          _buildHeader(),
          const Divider(height: 1),
          Expanded(
            child: _buildItemsArea(context),
          ),
          const Divider(height: 1),
          _buildBottomBar(),
        ],
      ),
    );
  }

  /* ===================== UI SECTIONS ===================== */

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping date: ${widget.shoppingDate.year}-${widget.shoppingDate.month.toString().padLeft(2, '0')}-${widget.shoppingDate.day.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 4),
          Text(
            widget.importFromPrevious
                ? 'Started by importing previous month'
                : 'Started from scratch',
            style: const TextStyle(
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsArea(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCategorySection('Cleaning'),
        const SizedBox(height: 16),
        _buildCategorySection('Food'),
        const SizedBox(height: 16),
        _buildAddItemButton(context),
      ],
    );
  }

  Widget _buildCategorySection(String category) {
    final entries = _entries
        .where((entry) => entry.item.category == category)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (entries.isEmpty)
          Container(
            padding: const EdgeInsets.all(12),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No items yet',
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          Column(
            children: entries.map((entry) {
              return _buildItemRow(entry);
            }).toList(),
          ),
      ],
    );
  }


  Widget _buildAddItemButton(BuildContext context) {
    return TextButton.icon(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return AddItemBottomSheet(
              onItemsSelected: (items) {
                setState(() {
                  for (final item in items) {
                    final exists = _entries.any(
                      (entry) => entry.item.name == item.name,
                    );
                    if (!exists) {
                      _entries.add(ListEntry(item: item));
                    }
                  }
                });
              },
            );
          },
        );
      },
      icon: const Icon(Icons.add),
      label: const Text('Add Item'),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Total'),
          Text(
            'Rs. 0',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(ListEntry entry) {
    return ListTile(
      title: Text(entry.item.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: entry.quantity > 1
                ? () {
                    setState(() {
                      entry.quantity--;
                    });
                  }
                : null,
          ),
          Text(
            entry.quantity.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              setState(() {
                entry.quantity++;
              });
            },
          ),
        ],
      ),
    );
  }
}
