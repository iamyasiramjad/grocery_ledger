import 'package:hive_flutter/hive_flutter.dart';

import 'features/grocery_list/storage/hive_grocery_list.dart';
import 'features/grocery_list/storage/hive_list_entry.dart';
import 'package:flutter/material.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  // ✅ REGISTER ADAPTERS (CRITICAL)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HiveGroceryListAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HiveListEntryAdapter());
  }

  runApp(const GroceryLedgerApp());
}
