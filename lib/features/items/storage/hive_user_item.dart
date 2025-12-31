import 'package:hive/hive.dart';

part 'hive_user_item.g.dart';

/// A Hive model representing a user-defined grocery item.
/// This allows users to add custom items to their catalog.
@HiveType(typeId: 4)
class HiveUserItem extends HiveObject {
  /// Unique identifier for the item (e.g., UUID or timestamp).
  /// This field is immutable once created.
  @HiveField(0)
  final String id;

  /// The display name of the grocery item.
  /// This field can be edited by the user later.
  @HiveField(1)
  String name;

  /// Reference to the [HiveUserCategory.id] this item belongs to.
  /// Using ID ensures the relationship survives if the category is renamed.
  @HiveField(2)
  String categoryId;

  HiveUserItem({
    required this.id,
    required this.name,
    required this.categoryId,
  });
}
