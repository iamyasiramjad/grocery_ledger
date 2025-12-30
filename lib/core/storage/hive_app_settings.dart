import 'package:hive/hive.dart';

part 'hive_app_settings.g.dart';

/// Hive model for storing app-level configuration.
///
/// This is a SINGLE-RECORD model, not a list-based storage.
/// Store in a box called 'app_settings' with a fixed key 'settings'.
///
/// Example usage:
/// ```dart
/// final box = await Hive.openBox<HiveAppSettings>('app_settings');
/// final settings = box.get('settings') ?? HiveAppSettings();
/// ```
@HiveType(typeId: 2)
class HiveAppSettings extends HiveObject {
  /// Whether the user has completed the onboarding flow.
  /// When false, the onboarding screen should be shown on app launch.
  @HiveField(0, defaultValue: false)
  bool hasCompletedOnboarding;

  HiveAppSettings({
    this.hasCompletedOnboarding = false,
  });
}
