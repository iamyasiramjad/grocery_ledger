import 'dart:async';
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
  /// The current name of the list, which can be edited.
  late String _listName;
  /// Whether the user is currently editing the list name inline in the AppBar.
  bool _isEditingName = false;
  /// Focus node for the name editing text field.
  final FocusNode _nameFocusNode = FocusNode();
  
  /// UI State for the "Saved" indicator
  bool _showSavedIndicator = false;
  Timer? _savedTimer;

  /// Controllers for input fields to prevent focus loss during auto-save
  final TextEditingController _adjustmentController = TextEditingController();
  final Map<ListEntry, (TextEditingController unit, TextEditingController total)> _entryControllers = {};

  late Box<HiveGroceryList> _groceryListBox;

  // ===================== LIFECYCLE =====================

  @override
  void initState() {
    super.initState();
    _currentKey = widget.existingListKey;
    _listName = widget.listName;
    _openBox().then((_) {
      setState(() {
        _loadExistingList();
      });
      _saveList(); // initial save (now safe)
    });
  }


  @override
  void dispose() {
    _nameFocusNode.dispose();
    _savedTimer?.cancel();
    _adjustmentController.dispose();
    for (final controllers in _entryControllers.values) {
      controllers.$1.dispose();
      controllers.$2.dispose();
    }
    super.dispose();
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
      final entry = ListEntry(
        item: StaticItem(
          hiveEntry.itemName,
          hiveEntry.category,
        ),
        quantity: hiveEntry.quantity,
        unitPrice: hiveEntry.unitPrice,
        totalPrice: hiveEntry.totalPrice,
      );
      _entries.add(entry);
      _initControllersForEntry(entry);
    }
    
    _adjustmentController.text = _adjustment == 0 ? '' : _adjustment.toStringAsFixed(0);
  }

  void _initControllersForEntry(ListEntry entry) {
    if (!_entryControllers.containsKey(entry)) {
      final unitText = entry.unitPrice != null ? entry.unitPrice!.toStringAsFixed(0) : '';
      final totalText = entry.hasPrice ? entry.calculatedTotal.toStringAsFixed(0) : '';

      _entryControllers[entry] = (
        TextEditingController(text: unitText),
        TextEditingController(text: totalText),
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
      name: _listName,
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
      // New record - create immediately in Hive to ensure it exists
      final newKey = await _groceryListBox.add(hiveList);
      setState(() {
        _currentKey = newKey;
      });
    }

    // Update the "Saved" indicator with a temporary appearance
    _savedTimer?.cancel();
    setState(() {
      _showSavedIndicator = true;
    });
    _savedTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSavedIndicator = false;
        });
      }
    });
  }


  // ===================== UI =====================

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _isEditingName
            ? TextField(
                focusNode: _nameFocusNode,
                autofocus: true,
                controller: TextEditingController(text: _listName),
                style: theme.textTheme.titleLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'List name',
                ),
                onSubmitted: _saveNewName,
              )
            : InkWell(
                onTap: _toggleEditName,
                child: Text(_listName),
              ),
        actions: [
          AnimatedOpacity(
            opacity: _showSavedIndicator ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Saved',
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  void _toggleEditName() {
    setState(() {
      _isEditingName = true;
    });
  }

  void _saveNewName(String value) {
    final newName = value.trim();
    if (newName.isNotEmpty) {
      _updateState(() {
        _listName = newName;
        _isEditingName = false;
      });
    } else {
      setState(() {
        _isEditingName = false;
      });
    }
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
    // Get unique categories from current entries to show them all dynamically
    final categories = _entries.map((e) => e.item.category).toSet().toList();
    categories.sort();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        for (final category in categories) ...[
          _buildCategorySection(category),
          const SizedBox(height: 16),
        ],
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
                      final newEntry = ListEntry(item: item);
                      _entries.add(newEntry);
                      _initControllersForEntry(newEntry);
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    entry.item.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                  onPressed: () {
                    _updateState(() {
                      _entries.remove(entry);
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildQuantityControls(entry),
                const Spacer(),
                _buildPriceInput(entry),
              ],
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
              ? () {
                  _updateState(() {
                    entry.quantity--;
                    // Update total controller if unit price exists
                    if (entry.unitPrice != null) {
                      _entryControllers[entry]?.$2.text = 
                          entry.calculatedTotal.toStringAsFixed(0);
                    }
                  });
                }
              : null,
        ),
        Text(entry.quantity.toString()),
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _updateState(() {
              entry.quantity++;
              // Update total controller if unit price exists
              if (entry.unitPrice != null) {
                _entryControllers[entry]?.$2.text = 
                    entry.calculatedTotal.toStringAsFixed(0);
              }
            });
          },
        ),
      ],
    );
  }

  Widget _buildPriceInput(ListEntry entry) {
    _initControllersForEntry(entry);
    final controllers = _entryControllers[entry]!;

    return Row(
      children: [
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: controllers.$1,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Unit Rs.',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final price = double.tryParse(value);
              _updateState(() {
                entry.unitPrice = price;
                if (price != null) {
                  entry.totalPrice = null;
                  // Automatically update the "Total Rs." field
                  controllers.$2.text = entry.calculatedTotal.toStringAsFixed(0);
                } else {
                  controllers.$2.clear();
                }
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: TextFormField(
            controller: controllers.$2,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Total Rs.',
              isDense: true,
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              final price = double.tryParse(value);
              _updateState(() {
                entry.totalPrice = price;
                if (price != null) {
                  entry.unitPrice = null;
                  // Clear "Unit Rs." if manual total is entered
                  controllers.$1.clear();
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
                child: TextFormField(
                  controller: _adjustmentController,
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
