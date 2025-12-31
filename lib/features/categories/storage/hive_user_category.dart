import 'package:hive/hive.dart';

part 'hive_user_category.g.dart';

/// A Hive model representing a user-defined grocery category.
/// This allows users to extend the built-in categories with their own.
@HiveType(typeId: 3)
class HiveUserCategory extends HiveObject {
  /// Unique identifier for the category (e.g., UUID or timestamp).
  /// This field is immutable once created.
  @HiveField(0)
  final String id;

  /// The display name of the category.
  /// This field can be edited by the user later.
  @HiveField(1)
  String name;

  HiveUserCategory({
    required this.id,
    required this.name,
  });
}
