import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/models/worship_model.dart';
import 'package:islamic_daily_tracker/data/models/daily_record.dart';
import 'package:uuid/uuid.dart';

class WorshipLocalDatasource {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  WorshipLocalDatasource(this._dbHelper);

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<WorshipModel>> getAllWorships({bool includeInactive = false, bool includeRamadan = false}) async {
    final db = await _dbHelper.database;
    String where = '';
    List<dynamic> args = [];
    if (!includeInactive) {
      where = 'is_active = 1';
    }
    if (!includeRamadan) {
      if (where.isNotEmpty) where += ' AND ';
      where += 'is_ramadan_only = 0';
    }
    final results = await db.query('worships', where: where.isEmpty ? null : where, whereArgs: args.isEmpty ? null : args, orderBy: 'sort_order ASC');
    return results.map((e) => WorshipModel.fromMap(e)).toList();
  }

  Future<void> addWorship(WorshipModel worship) async {
    final db = await _dbHelper.database;
    await db.insert('worships', worship.toMap());
  }

  Future<void> updateWorship(WorshipModel worship) async {
    final db = await _dbHelper.database;
    await db.update('worships', worship.toMap(), where: 'id = ?', whereArgs: [worship.id]);
  }

  Future<void> deleteWorship(String id) async {
    final db = await _dbHelper.database;
    await db.delete('worships', where: 'id = ?', whereArgs: [id]);
    await db.delete('daily_records', where: 'worship_id = ?', whereArgs: [id]);
  }

  Future<List<DailyRecord>> getRecordsByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final results = await db.query('daily_records', where: 'date = ?', whereArgs: [_dateStr(date)]);
    return results.map((e) => DailyRecord.fromMap(e)).toList();
  }

  Future<void> saveRecord(DailyRecord record) async {
    final db = await _dbHelper.database;
    final existing = await db.query('daily_records',
        where: 'worship_id = ? AND date = ?',
        whereArgs: [record.worshipId, _dateStr(record.date)]);
    if (existing.isNotEmpty) {
      await db.update('daily_records', record.toMap(),
          where: 'worship_id = ? AND date = ?',
          whereArgs: [record.worshipId, _dateStr(record.date)]);
    } else {
      final map = record.copyWith(id: _uuid.v4()).toMap();
      await db.insert('daily_records', map);
    }
  }

  Future<List<DailyRecord>> getRecordsByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final results = await db.query('daily_records',
        where: 'date >= ? AND date <= ?', whereArgs: [_dateStr(start), _dateStr(end)]);
    return results.map((e) => DailyRecord.fromMap(e)).toList();
  }
}
