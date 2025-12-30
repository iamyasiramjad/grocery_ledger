import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../../core/utils/static_items.dart';
import '../models/grocery_item.dart';
import '../models/list_entry.dart';
import '../storage/hive_grocery_list.dart';
import '../storage/hive_list_entry.dart';
import 'add_item_bottom_sheet.dart';

class GroceryListWorkspaceScreen extends StatefulWidget {
  final String listName;
  final DateTime shoppingDate;
  final bool importFromPrevious;
  final HiveGroceryList? existingList;
  /// The Hive key of the existing list (for updates, to avoid duplicates)
  final dynamic existingListKey;

  const GroceryListWorkspaceScreen({
    super.key,
    required this.listName,
    required this.shoppingDate,
    required this.importFromPrevious,
    this.existingList,
    this.existingListKey,
  });

  @override
  State<GroceryListWorkspaceScreen> createState() =>
      _GroceryListWorkspaceScreenState();
}

class _GroceryListWorkspaceScreenState
    extends State<GroceryListWorkspaceScreen> {
  // ===================== STATE =====================
  bool _boxReady = false;
  final List<ListEntry> _entries = [];
  double _adjustment = 0;
  /// The current Hive key for this list. Null for new lists until first save.
  dynamic _currentKey;

  late Box<HiveGroceryList> _groceryListBox;

  // ===================== LIFECYCLE =====================

  @override
  void initState() {
    super.initState();
    _currentKey = widget.existingListKey;
    _openBox().then((_) {
      setState(() {
        _loadExistingList();
      });
      _saveList(); // initial save (now safe)
    });
  }


  Future<void> _openBox() async {
    _groceryListBox = await Hive.openBox<HiveGroceryList>('grocery_lists');
    _boxReady = true;
  }


  // ===================== LOAD FROM HIVE =====================


  void _loadExistingList() {
    final list = widget.existingList;
    if (list == null) return;

    _adjustment = list.adjustment;
    _entries.clear();

    for (final hiveEntry in list.entries) {
      _entries.add(
        ListEntry(
          item: StaticItem(
            hiveEntry.itemName,
            hiveEntry.category,
          ),
          quantity: hiveEntry.quantity,
          unitPrice: hiveEntry.unitPrice,
          totalPrice: hiveEntry.totalPrice,
        ),
      );
    }
  }


  // ===================== HELPERS =====================

  void _updateState(VoidCallback action) {
    setState(action);
    _saveList();
  }

  double _calculateGrandTotal() {
    final itemsTotal = _entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.calculatedTotal,
    );
    return itemsTotal + _adjustment;
  }

  HiveGroceryList _toHiveModel() {
    return HiveGroceryList(
      name: widget.listName,
      date: widget.shoppingDate,
      adjustment: _adjustment,
      entries: _entries.map((entry) {
        return HiveListEntry(
          itemName: entry.item.name,
          category: entry.item.category,
          quantity: entry.quantity,
          unitPrice: entry.unitPrice,
          totalPrice: entry.totalPrice,
        );
      }).toList(),
    );
  }

  Future<void> _saveList() async {
    if (!_boxReady) return;

    final hiveList = _toHiveModel();
    
    if (_currentKey != null) {
      // Update existing record
      await _groceryListBox.put(_currentKey, hiveList);
    } else {
      // New record - let Hive auto-increment
      final newKey = await _groceryListBox.add(hiveList);
      setState(() {
        _currentKey = newKey;
      });
    }
  }


  // ===================== UI =====================

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
          Expanded(child: _buildItemsArea(context)),
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
            'Shopping date: '
            '${widget.shoppingDate.year}-'
            '${widget.shoppingDate.month.toString().padLeft(2, '0')}-'
            '${widget.shoppingDate.day.toString().padLeft(2, '0')}',
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
    final entries =
        _entries.where((e) => e.item.category == category).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
            children: entries.map(_buildItemRow).toList(),
          ),
      ],
    );
  }

  Widget _buildAddItemButton(BuildContext context) {
    return TextButton.icon(
      icon: const Icon(Icons.add),
      label: const Text('Add Item'),
      onPressed: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (_) {
            return AddItemBottomSheet(
              onItemsSelected: (items) {
                _updateState(() {
                  for (final item in items) {
                    final exists =
                        _entries.any((e) => e.item.name == item.name);
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
    );
  }

  Widget _buildItemRow(ListEntry entry) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              entry.item.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuantityControls(entry),
                const Spacer(),
                _buildPriceInput(entry),
              ],
            ),
            if (entry.hasPrice)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Total: Rs. ${entry.calculatedTotal.toStringAsFixed(0)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityControls(ListEntry entry) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove),
          onPressed: entry.quantity > 1
              ? () => _updateState(() => entry.quantity--)
              : null,
        ),
        Text(entry.quantity.toString()),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => _updateState(() => entry.quantity++),
        ),
      ],
    );
  }

  Widget _buildPriceInput(ListEntry entry) {
    return Row(
      children: [
        SizedBox(
          width: 90,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Unit Rs.',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final price = double.tryParse(value);
              _updateState(() {
                if (price != null) {
                  entry.unitPrice = price;
                  entry.totalPrice = null;
                } else {
                  entry.unitPrice = null;
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Rs.',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final price = double.tryParse(value);
              _updateState(() {
                if (price != null) {
                  entry.totalPrice = price;
                  entry.unitPrice = null;
                } else {
                  entry.totalPrice = null;
                }
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    final itemsTotal = _entries.fold<double>(
      0.0,
      (sum, entry) => sum + entry.calculatedTotal,
    );

    final grandTotal = itemsTotal + _adjustment;

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal'),
              Text('Rs. ${itemsTotal.toStringAsFixed(0)}'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: Text('Adjustment')),
              SizedBox(
                width: 120,
                child: TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: '-100 for discount',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    _updateState(() {
                      _adjustment = double.tryParse(value) ?? 0;
                    });
                  },
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                'Rs. ${grandTotal.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
