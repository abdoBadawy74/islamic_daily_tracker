import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/providers.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/data/models/quran_progress.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';
import 'package:islamic_daily_tracker/features/quran/data/surah_data.dart';
import 'package:islamic_daily_tracker/features/quran/data/quran_repository.dart';
import 'package:uuid/uuid.dart';

// Quran Text Repository & Surah Detail Providers
final quranTextRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepository();
});

final surahDetailProvider =
    FutureProvider.family.autoDispose<SurahFullModel, int>((ref, surahNumber) async {
  final repo = ref.watch(quranTextRepositoryProvider);
  return repo.getSurah(surahNumber);
});

// Search Query for Surahs
final surahSearchQueryProvider = StateProvider<String>((ref) => '');

// Filtered Surah list
final filteredSurahsProvider = Provider<List<SurahInfo>>((ref) {
  final query = ref.watch(surahSearchQueryProvider).trim().toLowerCase();
  if (query.isEmpty) return QuranData.surahs;

  return QuranData.surahs.where((s) {
    return s.nameArabic.contains(query) ||
        s.nameEnglish.toLowerCase().contains(query) ||
        s.number.toString() == query;
  }).toList();
});

// Today's Quran Progress
final todayQuranProgressProvider = FutureProvider.autoDispose<QuranProgress>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final settings = await ref.watch(appSettingsProvider.future);
  final today = AppDateUtils.getDateOnly(DateTime.now());

  final existing = await repo.getProgressByDate(today);
  if (existing != null) return existing;

  return QuranProgress(
    id: const Uuid().v4(),
    date: today,
    dailyTarget: settings.dailyQuranTarget,
    pagesRead: 0,
  );
});

// Total Pages Read overall
final totalPagesReadProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  return repo.getTotalPagesRead();
});

// Reading History (last 30 records)
final quranHistoryProvider = FutureProvider.autoDispose<List<QuranProgress>>((ref) async {
  final repo = ref.watch(quranRepositoryProvider);
  final now = DateTime.now();
  final start = now.subtract(const Duration(days: 60));
  return repo.getProgressByDateRange(start, now);
});

// Quran Actions
class QuranActions {
  final Ref _ref;
  final _uuid = const Uuid();

  QuranActions(this._ref);

  Future<void> logReading({
    required int pagesRead,
    int? surahNumber,
    int? ayahNumber,
    String? surahName,
    String? notes,
  }) async {
    final repo = _ref.read(quranRepositoryProvider);
    final today = AppDateUtils.getDateOnly(DateTime.now());
    final current = await _ref.read(todayQuranProgressProvider.future);

    final updated = current.copyWith(
      id: current.id.isEmpty ? _uuid.v4() : current.id,
      date: today,
      pagesRead: current.pagesRead + pagesRead,
      surahNumber: surahNumber ?? current.surahNumber,
      ayahNumber: ayahNumber ?? current.ayahNumber,
      lastSurahName: surahName ?? current.lastSurahName,
      notes: notes ?? current.notes,
    );

    await repo.saveProgress(updated);
    _ref.invalidate(todayQuranProgressProvider);
    _ref.invalidate(totalPagesReadProvider);
    _ref.invalidate(quranHistoryProvider);
  }

  Future<void> updateLastPosition({
    required int surahNumber,
    required String surahName,
    int? ayahNumber,
  }) async {
    final repo = _ref.read(quranRepositoryProvider);
    final today = AppDateUtils.getDateOnly(DateTime.now());
    final current = await _ref.read(todayQuranProgressProvider.future);

    final updated = current.copyWith(
      id: current.id.isEmpty ? _uuid.v4() : current.id,
      date: today,
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      lastSurahName: surahName,
    );

    await repo.saveProgress(updated);
    _ref.invalidate(todayQuranProgressProvider);
  }
}

final quranActionsProvider = Provider<QuranActions>((ref) {
  return QuranActions(ref);
});
