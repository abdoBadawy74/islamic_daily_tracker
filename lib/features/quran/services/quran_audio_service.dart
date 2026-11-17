import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class ReciterInfo {
  final String id;
  final String nameArabic;
  final String subFolder;

  const ReciterInfo({
    required this.id,
    required this.nameArabic,
    required this.subFolder,
  });

  String getAyahAudioUrl(int surahNumber, int ayahNumberInSurah) {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahNumberInSurah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/$subFolder/$s$a.mp3';
  }
}

class QuranAudioService {
  static final QuranAudioService _instance = QuranAudioService._internal();
  factory QuranAudioService() => _instance;

  final AudioPlayer _player = AudioPlayer();

  static const List<ReciterInfo> availableReciters = [
    ReciterInfo(
      id: 'sudais',
      nameArabic: 'الشيخ عبد الرحمن السديس',
      subFolder: 'Abdurrahmaan_As-Sudais_192kbps',
    ),
    ReciterInfo(
      id: 'alafasy',
      nameArabic: 'الشيخ مشاري راشد العفاسي',
      subFolder: 'Alafasy_128kbps',
    ),
    ReciterInfo(
      id: 'muaiqly',
      nameArabic: 'الشيخ ماهر المعيقلي',
      subFolder: 'MaherAlMuaiqly128kbps',
    ),
    ReciterInfo(
      id: 'abdulbasit',
      nameArabic: 'الشيخ عبد الباسط عبد الصمد',
      subFolder: 'Abdul_Basit_Murattal_192kbps',
    ),
    ReciterInfo(
      id: 'ghamadi',
      nameArabic: 'الشيخ سعد الغامدي',
      subFolder: 'Ghamadi_40kbps',
    ),
    ReciterInfo(
      id: 'minshawi',
      nameArabic: 'الشيخ محمد صديق المنشاوي',
      subFolder: 'Minshawy_Murattal_128kbps',
    ),
    ReciterInfo(
      id: 'husary',
      nameArabic: 'الشيخ محمود خليل الحصري',
      subFolder: 'Husary_128kbps',
    ),
  ];

  ReciterInfo _selectedReciter = availableReciters[0];
  ReciterInfo get selectedReciter => _selectedReciter;

  int? _currentSurah;
  int? _currentAyah;
  int? _totalAyahsInSurah;
  bool _isPlaying = false;
  bool _isLoading = false;

  void Function(int ayahNumber)? onAyahChanged;
  void Function(bool isPlaying)? onPlaybackStateChanged;
  void Function(String error)? onError;

  QuranAudioService._internal() {
    _player.onPlayerStateChanged.listen((state) {
      final isNowPlaying = state == PlayerState.playing;
      if (_isPlaying != isNowPlaying) {
        _isPlaying = isNowPlaying;
        onPlaybackStateChanged?.call(_isPlaying);
      }
    });

    _player.onPlayerComplete.listen((_) {
      _handleAyahCompleted();
    });
  }

  bool get isPlaying => _isPlaying;
  bool get isLoading => _isLoading;
  int? get currentPlayingAyah => _currentAyah;
  int? get currentPlayingSurah => _currentSurah;

  void setReciter(ReciterInfo reciter) {
    if (_selectedReciter.id == reciter.id) return;
    _selectedReciter = reciter;
    if (_isPlaying && _currentSurah != null && _currentAyah != null) {
      playAyah(
        surahNumber: _currentSurah!,
        ayahNumber: _currentAyah!,
        totalAyahs: _totalAyahsInSurah ?? _currentAyah!,
      );
    }
  }

  Future<void> playAyah({
    required int surahNumber,
    required int ayahNumber,
    required int totalAyahs,
  }) async {
    _currentSurah = surahNumber;
    _currentAyah = ayahNumber;
    _totalAyahsInSurah = totalAyahs;
    _isLoading = true;
    onPlaybackStateChanged?.call(true);
    onAyahChanged?.call(ayahNumber);

    final url = _selectedReciter.getAyahAudioUrl(surahNumber, ayahNumber);

    try {
      await _player.stop();
      await _player.play(UrlSource(url));
      _isPlaying = true;
      _isLoading = false;
      onPlaybackStateChanged?.call(true);
    } catch (e) {
      _isLoading = false;
      _isPlaying = false;
      onPlaybackStateChanged?.call(false);
      debugPrint('Quran audio playback error: $e');
      onError?.call('تعذر تشغيل الصوت. يرجى التأكد من اتصال الإنترنت.');
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    onPlaybackStateChanged?.call(false);
  }

  Future<void> resume() async {
    if (_currentSurah != null && _currentAyah != null) {
      await _player.resume();
      _isPlaying = true;
      onPlaybackStateChanged?.call(true);
    }
  }

  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    onPlaybackStateChanged?.call(false);
  }

  Future<void> nextAyah() async {
    if (_currentSurah == null || _currentAyah == null || _totalAyahsInSurah == null) return;
    if (_currentAyah! < _totalAyahsInSurah!) {
      await playAyah(
        surahNumber: _currentSurah!,
        ayahNumber: _currentAyah! + 1,
        totalAyahs: _totalAyahsInSurah!,
      );
    }
  }

  Future<void> previousAyah() async {
    if (_currentSurah == null || _currentAyah == null || _totalAyahsInSurah == null) return;
    if (_currentAyah! > 1) {
      await playAyah(
        surahNumber: _currentSurah!,
        ayahNumber: _currentAyah! - 1,
        totalAyahs: _totalAyahsInSurah!,
      );
    }
  }

  void _handleAyahCompleted() {
    if (_currentSurah == null || _currentAyah == null || _totalAyahsInSurah == null) return;
    if (_currentAyah! < _totalAyahsInSurah!) {
      // Auto-advance to the next ayah!
      playAyah(
        surahNumber: _currentSurah!,
        ayahNumber: _currentAyah! + 1,
        totalAyahs: _totalAyahsInSurah!,
      );
    } else {
      _isPlaying = false;
      onPlaybackStateChanged?.call(false);
    }
  }

  Future<void> dispose() async {
    await _player.dispose();
  }
}
