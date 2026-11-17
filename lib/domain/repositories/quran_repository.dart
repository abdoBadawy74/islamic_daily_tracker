import 'package:islamic_daily_tracker/data/models/quran_progress.dart';

abstract class QuranRepository {
  Future<QuranProgress?> getProgressByDate(DateTime date);
  Future<void> saveProgress(QuranProgress progress);
  Future<List<QuranProgress>> getProgressByDateRange(DateTime start, DateTime end);
  Future<int> getTotalPagesRead();
}
