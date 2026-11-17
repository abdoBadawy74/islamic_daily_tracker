import 'package:islamic_daily_tracker/data/datasources/local/quran_local_datasource.dart';
import 'package:islamic_daily_tracker/data/models/quran_progress.dart';
import 'package:islamic_daily_tracker/domain/repositories/quran_repository.dart';

class QuranRepositoryImpl implements QuranRepository {
  final QuranLocalDatasource _datasource;

  QuranRepositoryImpl(this._datasource);

  @override
  Future<QuranProgress?> getProgressByDate(DateTime date) {
    return _datasource.getProgressByDate(date);
  }

  @override
  Future<void> saveProgress(QuranProgress progress) {
    return _datasource.saveProgress(progress);
  }

  @override
  Future<List<QuranProgress>> getProgressByDateRange(DateTime start, DateTime end) {
    return _datasource.getProgressByDateRange(start, end);
  }

  @override
  Future<int> getTotalPagesRead() {
    return _datasource.getTotalPagesRead();
  }
}
