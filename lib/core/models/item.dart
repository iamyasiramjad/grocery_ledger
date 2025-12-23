import 'category.dart';
import 'unit_type.dart';

class Item {
  final int id;
  final String name;
  final Category category;
  final UnitType unitType;
  final DateTime createdAt;
  final DateTime? archivedAt;

  const Item({
    required this.id,
    required this.name,
    required this.category,
    required this.unitType,
    required this.createdAt,
    this.archivedAt,
  });

  bool get isArchived => archivedAt != null;
}