import 'package:flutter/foundation.dart';

@immutable
class StaticItem {
  final String name;
  final String category;

  const StaticItem(this.name, this.category);
}

/// Default catalog shown when user adds items
const List<StaticItem> staticItems = [
  // 🧼 Cleaning
  StaticItem('Surf Excel', 'Cleaning'),
  StaticItem('Lifebuoy Soap', 'Cleaning'),
  StaticItem('Shampoo', 'Cleaning'),
  StaticItem('Dish Wash', 'Cleaning'),
  StaticItem('Floor Cleaner', 'Cleaning'),

  // 🍚 Food
  StaticItem('Rice', 'Food'),
  StaticItem('Daal', 'Food'),
  StaticItem('Eggs', 'Food'),
  StaticItem('Tea', 'Food'),
  StaticItem('Sugar', 'Food'),
  StaticItem('Milk', 'Food'),
];
