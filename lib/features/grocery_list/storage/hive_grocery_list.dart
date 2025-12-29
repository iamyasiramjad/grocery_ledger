import 'package:hive/hive.dart';
import 'hive_list_entry.dart';

part 'hive_grocery_list.g.dart';

@HiveType(typeId: 0)
class HiveGroceryList extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime date;

  @HiveField(2)
  double adjustment;

  @HiveField(3)
  List<HiveListEntry> entries;

  HiveGroceryList({
    required this.name,
    required this.date,
    this.adjustment = 0,
    required this.entries,
  });
}
