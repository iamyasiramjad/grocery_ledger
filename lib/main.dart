import 'package:hive_flutter/hive_flutter.dart';

import 'core/storage/hive_app_settings.dart';
import 'features/grocery_list/storage/hive_grocery_list.dart';
import 'features/grocery_list/storage/hive_list_entry.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/onboarding/onboarding_screen.dart';
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
  if (!Hive.isAdapterRegistered(2)) {
    Hive.registerAdapter(HiveAppSettingsAdapter());
  }

  // ─────────────────────────────────────────────────────────────────────────
  // APP LAUNCH ROUTING
  // ─────────────────────────────────────────────────────────────────────────
  // Open the app settings box and determine which screen to show first.
  // This decision is made BEFORE runApp() to prevent any flicker.
  // ─────────────────────────────────────────────────────────────────────────

  final settingsBox = await Hive.openBox<HiveAppSettings>('app_settings');

  // Read settings record; if none exists, treat as first launch
  final settings = settingsBox.get('settings') ?? HiveAppSettings();

  // Determine initial screen based on onboarding completion status
  final Widget initialScreen = settings.hasCompletedOnboarding
      ? const DashboardScreen()
      : OnboardingScreen(settingsBox: settingsBox);

  runApp(GroceryLedgerApp(home: initialScreen));
}

