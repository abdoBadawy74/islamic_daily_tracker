import 'package:islamic_daily_tracker/data/models/azkar_model.dart';

abstract class AzkarRepository {
  Future<List<AzkarCategory>> getCategories();
  Future<List<AzkarItem>> getItemsByCategory(String categoryId);
  Future<List<AzkarItem>> getAllItems();
  Future<void> updateItemCount(String itemId, int newCount);
  Future<List<AzkarProgress>> getProgressByDate(DateTime date);
  Future<void> saveProgress(AzkarProgress progress);
  Future<void> resetDailyProgress(DateTime date);
}
