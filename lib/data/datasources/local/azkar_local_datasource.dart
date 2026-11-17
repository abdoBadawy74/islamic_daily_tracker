import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';

class AzkarLocalDatasource {
  final DatabaseHelper _dbHelper;

  AzkarLocalDatasource(this._dbHelper);

  String _dateStr(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<List<AzkarCategory>> getCategories() async {
    final db = await _dbHelper.database;
    final results = await db.query('azkar_categories');
    return results.map((e) => AzkarCategory.fromMap(e)).toList();
  }

  Future<List<AzkarItem>> getItemsByCategory(String categoryId) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'azkar_items',
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return results.map((e) => AzkarItem.fromMap(e)).toList();
  }

  Future<List<AzkarItem>> getAllItems() async {
    final db = await _dbHelper.database;
    final results = await db.query('azkar_items');
    return results.map((e) => AzkarItem.fromMap(e)).toList();
  }

  Future<void> updateItemCount(String itemId, int newCount) async {
    final db = await _dbHelper.database;
    await db.update(
      'azkar_items',
      {'current_count': newCount},
      where: 'id = ?',
      whereArgs: [itemId],
    );
  }

  Future<List<AzkarProgress>> getProgressByDate(DateTime date) async {
    final db = await _dbHelper.database;
    final results = await db.query(
      'azkar_progress',
      where: 'date = ?',
      whereArgs: [_dateStr(date)],
    );
    return results.map((e) => AzkarProgress.fromMap(e)).toList();
  }

  Future<void> saveProgress(AzkarProgress progress) async {
    final db = await _dbHelper.database;
    final existing = await db.query(
      'azkar_progress',
      where: 'azkar_item_id = ? AND date = ?',
      whereArgs: [progress.azkarItemId, _dateStr(progress.date)],
    );
    if (existing.isNotEmpty) {
      await db.update(
        'azkar_progress',
        progress.toMap(),
        where: 'azkar_item_id = ? AND date = ?',
        whereArgs: [progress.azkarItemId, _dateStr(progress.date)],
      );
    } else {
      await db.insert('azkar_progress', progress.toMap());
    }
  }

  Future<void> resetDailyProgress(DateTime date) async {
    final db = await _dbHelper.database;
    await db.delete(
      'azkar_progress',
      where: 'date = ?',
      whereArgs: [_dateStr(date)],
    );
    await db.update('azkar_items', {'current_count': 0});
  }
}
