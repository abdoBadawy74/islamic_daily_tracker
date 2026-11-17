import 'package:islamic_daily_tracker/data/models/app_settings.dart';

abstract class SettingsRepository {
  Future<AppSettings> getSettings();
  Future<void> saveSetting(String key, String value);
  Future<void> saveAllSettings(AppSettings settings);
  Future<void> resetAllData();
}
