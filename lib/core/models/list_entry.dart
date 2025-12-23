import 'grocery_item.dart';
import 'item.dart';

class ListEntry {
  final int id;
  final GroceryList groceryList;
  final Item item;

  final double quantity;
  final double unitPrice;
  final double totalPrice;

  final DateTime createdAt;

  const ListEntry({
    required this.id,
    required this.groceryList,
    required this.item,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    required this.createdAt,
  });

  bool get isValid {
  return quantity > 0 && unitPrice >= 0 && totalPrice >= 0;
}

double get calculatedTotal => quantity * unitPrice;
}