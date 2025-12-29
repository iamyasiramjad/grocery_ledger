import 'package:hive/hive.dart';

part 'hive_list_entry.g.dart';

@HiveType(typeId: 1)
class HiveListEntry extends HiveObject {
  @HiveField(0)
  String itemName;

  @HiveField(1)
  String category;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  double? unitPrice;

  @HiveField(4)
  double? totalPrice;

  HiveListEntry({
    required this.itemName,
    required this.category,
    required this.quantity,
    this.unitPrice,
    this.totalPrice,
  });
}
