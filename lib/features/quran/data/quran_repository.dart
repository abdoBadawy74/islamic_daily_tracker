import 'dart:convert';
import 'package:flutter/services.dart';

class AyahModel {
  final int number; // Global number 1..6236
  final String text; // Raw Uthmani text
  final int numberInSurah;
  final int juz;
  final int manzil;
  final int page;
  final int ruku;
  final int hizbQuarter;
  final bool sajda;

  const AyahModel({
    required this.number,
    required this.text,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.sajda,
  });

  factory AyahModel.fromJson(Map<String, dynamic> json) {
    final sajdaVal = json['sajda'];
    final bool hasSajda = (sajdaVal is bool)
        ? sajdaVal
        : (sajdaVal != null && sajdaVal != false);

    return AyahModel(
      number: json['number'] as int,
      text: (json['text'] as String).trim(),
      numberInSurah: json['numberInSurah'] as int,
      juz: json['juz'] as int? ?? 1,
      manzil: json['manzil'] as int? ?? 1,
      page: json['page'] as int? ?? 1,
      ruku: json['ruku'] as int? ?? 1,
      hizbQuarter: json['hizbQuarter'] as int? ?? 1,
      sajda: hasSajda,
    );
  }

  /// Clean Uthmani text:
  /// For Surahs 2-114, ayah 1 usually includes the Basmala prefix in api.alquran.cloud.
  /// We strip it so the Basmala banner appears at the top cleanly and isn't repeated.
  String getUthmaniTextForSurah(int surahNumber) {
    if (surahNumber == 1 || surahNumber == 9) return text;
    const basmala1 = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';
    const basmala2 = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ';
    if (numberInSurah == 1) {
      if (text.startsWith(basmala2)) {
        return text.substring(basmala2.length).trim();
      } else if (text.startsWith(basmala1)) {
        return text.substring(basmala1.length).trim();
      }
    }
    return text;
  }
}

class SurahFullModel {
  final int number;
  final String nameArabic;
  final String englishName;
  final String revelationType;
  final List<AyahModel> ayahs;

  const SurahFullModel({
    required this.number,
    required this.nameArabic,
    required this.englishName,
    required this.revelationType,
    required this.ayahs,
  });

  Map<int, List<AyahModel>> get ayahsByPage {
    final Map<int, List<AyahModel>> pages = {};
    for (final ayah in ayahs) {
      pages.putIfAbsent(ayah.page, () => []).add(ayah);
    }
    return pages;
  }
}

class MushafAyahItem {
  final AyahModel ayah;
  final int surahNumber;
  final String surahName;

  const MushafAyahItem({
    required this.ayah,
    required this.surahNumber,
    required this.surahName,
  });
}

class QuranRepository {
  static final QuranRepository _instance = QuranRepository._internal();
  factory QuranRepository() => _instance;
  QuranRepository._internal();

  Map<int, SurahFullModel>? _surahsCache;
  Map<int, List<MushafAyahItem>>? _pagesMap;
  bool _isLoading = false;

  Future<void> _loadQuranData() async {
    if (_surahsCache != null) return;
    if (_isLoading) {
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 50));
      }
      return;
    }

    _isLoading = true;
    try {
      final jsonString = await rootBundle.loadString('assets/data/quran_uthmani.json');
      final decoded = json.decode(jsonString) as Map<String, dynamic>;
      final surahsList = (decoded['data']['surahs'] as List<dynamic>);

      final cache = <int, SurahFullModel>{};
      final pages = <int, List<MushafAyahItem>>{};

      for (final s in surahsList) {
        final surahMap = s as Map<String, dynamic>;
        final num = surahMap['number'] as int;
        final name = surahMap['name'] as String;
        final ayahs = (surahMap['ayahs'] as List<dynamic>)
            .map((a) => AyahModel.fromJson(a as Map<String, dynamic>))
            .toList();

        cache[num] = SurahFullModel(
          number: num,
          nameArabic: name,
          englishName: surahMap['englishName'] as String,
          revelationType: surahMap['revelationType'] as String,
          ayahs: ayahs,
        );

        for (final ayah in ayahs) {
          pages.putIfAbsent(ayah.page, () => []).add(
            MushafAyahItem(
              ayah: ayah,
              surahNumber: num,
              surahName: name,
            ),
          );
        }
      }
      _surahsCache = cache;
      _pagesMap = pages;
    } finally {
      _isLoading = false;
    }
  }

  Future<SurahFullModel> getSurah(int surahNumber) async {
    await _loadQuranData();
    final surah = _surahsCache?[surahNumber];
    if (surah == null) {
      throw Exception('Surah $surahNumber not found');
    }
    return surah;
  }

  Future<List<AyahModel>> getAyahs(int surahNumber) async {
    final surah = await getSurah(surahNumber);
    return surah.ayahs;
  }

  Future<Map<int, List<MushafAyahItem>>> getAllPages() async {
    await _loadQuranData();
    return _pagesMap ?? {};
  }

  Future<List<MushafAyahItem>> getPageAyahs(int pageNumber) async {
    final pages = await getAllPages();
    return pages[pageNumber] ?? [];
  }
}
