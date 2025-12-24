import 'package:flutter/material.dart';
import 'add_item_bottom_sheet.dart';
import '../../../core/utils/static_items.dart';


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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Shopping date: ${shoppingDate.year}-${shoppingDate.month.toString().padLeft(2, '0')}-${shoppingDate.day.toString().padLeft(2, '0')}',
          ),
          const SizedBox(height: 4),
          Text(
            importFromPrevious
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

  Widget _buildCategorySection(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
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
              onItemSelected: (item) {
                // TEMP: confirm selection
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${item.name} selected'),
                  ),
                );
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            'Total',
            style: TextStyle(fontSize: 16),
          ),
          Text(
            'Rs. 0',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


}
