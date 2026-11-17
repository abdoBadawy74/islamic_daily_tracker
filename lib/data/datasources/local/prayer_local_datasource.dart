import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/models/prayer_status.dart';
import 'package:uuid/uuid.dart';

class PrayerLocalDatasource {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  PrayerLocalDatasource(this._dbHelper);

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<PrayerStatus>> getPrayersByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final results = await db.query('prayers', where: 'date = ?', whereArgs: [_dateStr(date)]);
    return results.map((e) => PrayerStatus.fromMap(e)).toList();
  }

  Future<void> savePrayerStatus(PrayerStatus status) async {
    final db = await _dbHelper.database;
    final existing = await db.query('prayers',
        where: 'prayer_name = ? AND date = ?',
        whereArgs: [status.prayerName, _dateStr(status.date)]);
    if (existing.isNotEmpty) {
      await db.update('prayers', status.toMap(),
          where: 'prayer_name = ? AND date = ?',
          whereArgs: [status.prayerName, _dateStr(status.date)]);
    } else {
      final map = status.copyWith(id: _uuid.v4()).toMap();
      await db.insert('prayers', map);
    }
  }

  Future<List<PrayerStatus>> getPrayerStatsByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final results = await db.query('prayers',
        where: 'date >= ? AND date <= ?', whereArgs: [_dateStr(start), _dateStr(end)]);
    return results.map((e) => PrayerStatus.fromMap(e)).toList();
  }
}
