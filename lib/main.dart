import 'core/auth/auth_gate.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/storage/hive_app_settings.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
import 'features/grocery_list/storage/hive_grocery_list.dart';
import 'features/grocery_list/storage/hive_list_entry.dart';
import 'features/categories/storage/hive_user_category.dart';
import 'features/items/storage/hive_user_item.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ SUPABASE INIT (IDENTITY FIRST)
  // ─────────────────────────────────────────────────────────────────────────
  await Supabase.initialize(
    url: 'https://fqueulhpoaximhsyvgyg.supabase.co',
    anonKey: 'sb_publishable_oHHElcX7s8y_L8rZiTAo7g_3FONBfj0',
  );

  // ─────────────────────────────────────────────────────────────────────────
  // ✅ HIVE INIT (LOCAL STORAGE)
  // ─────────────────────────────────────────────────────────────────────────
  await Hive.initFlutter();

  // ✅ REGISTER ADAPTERS (CRITICAL)
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(HiveGroceryListAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(HiveListEntryAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HiveAppSettingsAdapter());
  }
  if (!Hive.isAdapterRegistered(3)) {
    Hive.registerAdapter(HiveUserCategoryAdapter());
  }
  if (!Hive.isAdapterRegistered(4)) {
    Hive.registerAdapter(HiveUserItemAdapter());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APP LAUNCH ROUTING (ONBOARDING ONLY FOR NOW)
  // ─────────────────────────────────────────────────────────────────────────

  final settingsBox = await Hive.openBox<HiveAppSettings>('app_settings');
  final settings = settingsBox.get('settings') ?? HiveAppSettings();

  final Widget initialScreen = settings.hasCompletedOnboarding
      ? const DashboardScreen()
      : OnboardingScreen(settingsBox: settingsBox);

  runApp(
    GroceryLedgerApp(
      home: AuthGate(
        authenticated: initialScreen,
      ),
    ),
  );


}
