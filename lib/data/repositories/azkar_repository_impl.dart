import 'package:islamic_daily_tracker/data/datasources/local/azkar_local_datasource.dart';
import 'package:islamic_daily_tracker/data/models/azkar_model.dart';
import 'package:islamic_daily_tracker/domain/repositories/azkar_repository.dart';

class AzkarRepositoryImpl implements AzkarRepository {
  final AzkarLocalDatasource _datasource;

  AzkarRepositoryImpl(this._datasource);

  @override
  Future<List<AzkarCategory>> getCategories() {
    return _datasource.getCategories();
  }

  @override
  Future<List<AzkarItem>> getItemsByCategory(String categoryId) {
    return _datasource.getItemsByCategory(categoryId);
  }

  @override
  Future<List<AzkarItem>> getAllItems() {
    return _datasource.getAllItems();
  }

  @override
  Future<void> updateItemCount(String itemId, int newCount) {
    return _datasource.updateItemCount(itemId, newCount);
  }

  @override
  Future<List<AzkarProgress>> getProgressByDate(DateTime date) {
    return _datasource.getProgressByDate(date);
  }

  @override
  Future<void> saveProgress(AzkarProgress progress) {
    return _datasource.saveProgress(progress);
  }

  @override
  Future<void> resetDailyProgress(DateTime date) {
    return _datasource.resetDailyProgress(date);
  }
}
