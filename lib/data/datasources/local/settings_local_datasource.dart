import 'package:sqflite/sqflite.dart';
import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/models/app_settings.dart';

class SettingsLocalDatasource {
  final DatabaseHelper _dbHelper;

  SettingsLocalDatasource(this._dbHelper);

  Future<AppSettings> getSettings() async {
    final db = await _dbHelper.database;
    final results = await db.query('app_settings');
    final Map<String, String> map = {};
    for (final row in results) {
      map[row['key'] as String] = row['value'] as String;
    }
    return AppSettings.fromMap(map);
  }

  Future<void> saveSetting(String key, String value) async {
    final db = await _dbHelper.database;
    await db.insert(
      'app_settings',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> saveAllSettings(AppSettings settings) async {
    final db = await _dbHelper.database;
    final batch = db.batch();
    settings.toMap().forEach((key, value) {
      batch.insert(
        'app_settings',
        {'key': key, 'value': value},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    await batch.commit(noResult: true);
  }

  Future<void> resetAllData() async {
    final db = await _dbHelper.database;
    await db.delete('prayers');
    await db.delete('daily_records');
    await db.delete('quran_progress');
    await db.delete('azkar_progress');
    await db.update('azkar_items', {'current_count': 0});
  }
}
