import '../../../core/utils/static_items.dart';

class ListEntry {
  final StaticItem item;

  int quantity;

  double? unitPrice;
  double? totalPrice;

  ListEntry({
    required this.item,
    this.quantity = 1,
    this.unitPrice,
    this.totalPrice,
  });

  /// Helper getters
  bool get hasPrice => unitPrice != null || totalPrice != null;

  double get calculatedTotal {
    if (totalPrice != null) return totalPrice!;
    if (unitPrice != null) return unitPrice! * quantity;
    return 0;
  }

  double get calculatedUnitPrice {
    if (unitPrice != null) return unitPrice!;
    if (totalPrice != null && quantity > 0) {
      return totalPrice! / quantity;
    }
    return 0;
  }
}
