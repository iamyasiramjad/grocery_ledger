import '../../../core/utils/static_items.dart';

class ListEntry {
  final StaticItem item;
  int quantity;

  ListEntry({
    required this.item,
    this.quantity = 1,
  });
}
