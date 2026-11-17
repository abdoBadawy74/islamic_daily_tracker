import 'package:islamic_daily_tracker/data/datasources/local/settings_local_datasource.dart';
import 'package:islamic_daily_tracker/data/models/app_settings.dart';
import 'package:islamic_daily_tracker/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDatasource _datasource;

  SettingsRepositoryImpl(this._datasource);

  @override
  Future<AppSettings> getSettings() {
    return _datasource.getSettings();
  }

  @override
  Future<void> saveSetting(String key, String value) {
    return _datasource.saveSetting(key, value);
  }

  @override
  Future<void> saveAllSettings(AppSettings settings) {
    return _datasource.saveAllSettings(settings);
  }

  @override
  Future<void> resetAllData() {
    return _datasource.resetAllData();
  }
}
