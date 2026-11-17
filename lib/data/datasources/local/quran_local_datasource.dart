import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/models/quran_progress.dart';
import 'package:uuid/uuid.dart';

class QuranLocalDatasource {
  final DatabaseHelper _dbHelper;
  final _uuid = const Uuid();

  QuranLocalDatasource(this._dbHelper);

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<QuranProgress?> getProgressByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final results = await db.query('quran_progress', where: 'date = ?', whereArgs: [_dateStr(date)]);
    if (results.isEmpty) return null;
    return QuranProgress.fromMap(results.first);
  }

  Future<void> saveProgress(QuranProgress progress) async {
    final db = await _dbHelper.database;
    final existing = await db.query('quran_progress', where: 'date = ?', whereArgs: [_dateStr(progress.date)]);
    if (existing.isNotEmpty) {
      await db.update('quran_progress', progress.toMap(), where: 'date = ?', whereArgs: [_dateStr(progress.date)]);
    } else {
      final map = progress.copyWith(id: _uuid.v4()).toMap();
      await db.insert('quran_progress', map);
    }
  }

  Future<List<QuranProgress>> getProgressByDateRange(DateTime start, DateTime end) async {
    final db = await _dbHelper.database;
    final results = await db.query('quran_progress',
        where: 'date >= ? AND date <= ?', whereArgs: [_dateStr(start), _dateStr(end)], orderBy: 'date DESC');
    return results.map((e) => QuranProgress.fromMap(e)).toList();
  }

  Future<int> getTotalPagesRead() async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('SELECT SUM(pages_read) as total FROM quran_progress');
    return (result.first['total'] as int?) ?? 0;
  }
}
