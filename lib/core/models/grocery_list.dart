import 'month.dart';

class GroceryList {
  final int id;
  final Month month;
  final String name;
  final String storeName;
  final DateTime shoppingDate;
  final double disccountAmount;
  final DateTime createdAt;
  final DateTime? finalizedAt;

  const GroceryList({
    required this.id,
    required this.month,
    required this.name,
    required this.storeName,
    required this.shoppingDate,
    this.disccountAmount = 0.0,
    required this.createdAt,
    this.finalizedAt,
  });

  bool get isFinalized => finalizedAt != null;
}