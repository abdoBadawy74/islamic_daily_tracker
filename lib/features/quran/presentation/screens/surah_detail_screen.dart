import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/quran/data/quran_repository.dart';
import 'package:islamic_daily_tracker/features/quran/data/surah_data.dart';
import 'package:islamic_daily_tracker/features/quran/presentation/widgets/log_reading_dialog.dart';
import 'package:islamic_daily_tracker/features/quran/providers/quran_providers.dart';
import 'package:islamic_daily_tracker/features/quran/services/quran_audio_service.dart';

enum QuranViewMode { mushafContinuous, ayahByAyah }

class SurahDetailScreen extends ConsumerStatefulWidget {
  final SurahInfo surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  late SurahInfo _currentSurah;
  QuranViewMode _viewMode = QuranViewMode.mushafContinuous;
  double _fontSize = 22.0;

  final QuranAudioService _audioService = QuranAudioService();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  int _currentPlayingAyah = 1;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;

    _audioService.onAyahChanged = (ayahNum) {
      if (!mounted) return;
      setState(() => _currentPlayingAyah = ayahNum);
    };

    _audioService.onPlaybackStateChanged = (playing) {
      if (!mounted) return;
      setState(() {
        _isPlaying = playing;
        _isLoadingAudio = _audioService.isLoading;
      });
    };

    _audioService.onError = (msg) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: Colors.red.shade700,
          duration: const Duration(seconds: 3),
        ),
      );
    };
  }

  @override
  void dispose() {
    _audioService.stop();
    _scrollController.dispose();
    super.dispose();
  }

  void _switchSurah(SurahInfo newSurah) {
    _audioService.stop();
    setState(() {
      _currentSurah = newSurah;
      _currentPlayingAyah = 1;
      _isPlaying = false;
    });
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }

  Future<void> _togglePlayPause() async {
    if (_isPlaying) {
      await _audioService.pause();
    } else {
      await _audioService.playAyah(
        surahNumber: _currentSurah.number,
        ayahNumber: _currentPlayingAyah,
        totalAyahs: _currentSurah.ayahCount,
      );
    }
  }

  Future<void> _playSpecificAyah(int ayahNumber) async {
    setState(() => _currentPlayingAyah = ayahNumber);
    await _audioService.playAyah(
      surahNumber: _currentSurah.number,
      ayahNumber: ayahNumber,
      totalAyahs: _currentSurah.ayahCount,
    );
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(quranActionsProvider);
    final surahAsync = ref.watch(surahDetailProvider(_currentSurah.number));

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        title: _buildSurahSelector(),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == QuranViewMode.mushafContinuous
                  ? Icons.view_headline_rounded
                  : Icons.menu_book_rounded,
              color: AppColors.goldLight,
            ),
            tooltip: _viewMode == QuranViewMode.mushafContinuous
                ? 'عرض آية بآية'
                : 'عرض المصحف المتصل',
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == QuranViewMode.mushafContinuous
                    ? QuranViewMode.ayahByAyah
                    : QuranViewMode.mushafContinuous;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded, color: AppColors.goldLight),
            tooltip: 'حجم الخط',
            onPressed: _showFontSizeDialog,
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined, color: AppColors.goldLight),
            tooltip: 'حفظ الموضع كآخر قراءة',
            onPressed: () async {
              await actions.updateLastPosition(
                surahNumber: _currentSurah.number,
                surahName: _currentSurah.nameArabic,
                ayahNumber: _currentPlayingAyah,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'تم حفظ سورة ${_currentSurah.nameArabic} كآخر موضع قراءة',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    backgroundColor: AppColors.primary,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: surahAsync.when(
              data: (fullSurah) {
                if (_viewMode == QuranViewMode.mushafContinuous) {
                  return _buildFastMushafView(fullSurah);
                } else {
                  return _buildFastAyahByAyahView(fullSurah);
                }
              },
              loading: () => const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'جاري تحميل آيات السورة الكريمة...',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                    ),
                  ],
                ),
              ),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      const SizedBox(height: 12),
                      Text('تعذر تحميل السورة: $err'),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(surahDetailProvider(_currentSurah.number)),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildAudioPlayerBar(),
        ],
      ),
    );
  }

  Widget _buildSurahSelector() {
    return PopupMenuButton<SurahInfo>(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      initialValue: _currentSurah,
      onSelected: _switchSurah,
      itemBuilder: (context) {
        return QuranData.surahs.map((s) {
          final isSelected = s.number == _currentSurah.number;
          return PopupMenuItem<SurahInfo>(
            value: s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.beigeDark.withValues(alpha: 0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${s.number}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'سورة ${s.nameArabic}',
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${s.ayahCount} آية',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سورة ${_currentSurah.nameArabic}',
              style: const TextStyle(
                color: AppColors.goldLight,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_drop_down, color: AppColors.goldLight, size: 20),
          ],
        ),
      ),
    );
  }

  // High Performance Virtualized Mushaf View (Grouped by Mushaf Pages)
  Widget _buildFastMushafView(SurahFullModel fullSurah) {
    final pagesMap = fullSurah.ayahsByPage;
    final pagesList = pagesMap.entries.toList();

    // 0: Header & Basmala
    // 1..pagesList.length: Page Cards
    // pagesList.length + 1: End of Surah Banner
    final totalItems = 1 + pagesList.length + 1;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _buildSurahHeaderCard(fullSurah),
              const SizedBox(height: 14),
              if (_currentSurah.number != 9) _buildBasmalaBanner(),
              const SizedBox(height: 14),
            ],
          );
        }

        if (index == totalItems - 1) {
          return _buildEndOfSurahBadge();
        }

        final pageEntry = pagesList[index - 1];
        final pageNumber = pageEntry.key;
        final pageAyahs = pageEntry.value;

        return _buildMushafPageCard(pageNumber, pageAyahs);
      },
    );
  }

  // Single Mushaf Page Card (Flowing 5-8 verses continuously, virtualized)
  Widget _buildMushafPageCard(int pageNumber, List<AyahModel> ayahs) {
    final firstJuz = ayahs.first.juz;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Page Header Top Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الجزء $firstJuz',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.goldLight.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Text(
                  'صفحة $pageNumber',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldDark,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 16, color: Color(0xFFF0EAE1)),
          const SizedBox(height: 4),

          // Continuous Flow Text for this Page
          Directionality(
            textDirection: TextDirection.rtl,
            child: RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                style: GoogleFonts.amiri(
                  fontSize: _fontSize,
                  height: 2.2,
                  color: const Color(0xFF1F2937),
                ),
                children: ayahs.map((ayah) {
                  final displayText = ayah.getUthmaniTextForSurah(_currentSurah.number);
                  final isPlaying = _isPlaying && ayah.numberInSurah == _currentPlayingAyah;

                  return TextSpan(
                    children: [
                      TextSpan(
                        text: '$displayText ',
                        style: TextStyle(
                          backgroundColor: isPlaying
                              ? AppColors.emerald.withValues(alpha: 0.18)
                              : Colors.transparent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showAyahActionSheet(ayah),
                      ),
                      TextSpan(
                        text: ' ﴿${ayah.numberInSurah}﴾ ',
                        style: TextStyle(
                          fontSize: _fontSize * 0.75,
                          fontWeight: FontWeight.bold,
                          color: isPlaying ? AppColors.emerald : AppColors.primaryDark,
                          backgroundColor: isPlaying
                              ? AppColors.emerald.withValues(alpha: 0.18)
                              : Colors.transparent,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => _showAyahActionSheet(ayah),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // High Performance Virtualized Ayah by Ayah View
  Widget _buildFastAyahByAyahView(SurahFullModel fullSurah) {
    // 0: Header & Basmala
    // 1..ayahs.length: Ayah Cards
    // ayahs.length + 1: End of Surah Banner
    final totalItems = 1 + fullSurah.ayahs.length + 1;

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: totalItems,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Column(
            children: [
              _buildSurahHeaderCard(fullSurah),
              const SizedBox(height: 14),
              if (_currentSurah.number != 9) _buildBasmalaBanner(),
              const SizedBox(height: 14),
            ],
          );
        }

        if (index == totalItems - 1) {
          return _buildEndOfSurahBadge();
        }

        final ayah = fullSurah.ayahs[index - 1];
        final displayText = ayah.getUthmaniTextForSurah(_currentSurah.number);
        final isPlaying = _isPlaying && ayah.numberInSurah == _currentPlayingAyah;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isPlaying ? AppColors.emerald.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPlaying
                  ? AppColors.emerald
                  : AppColors.beigeDark.withValues(alpha: 0.5),
              width: isPlaying ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isPlaying ? AppColors.primary : AppColors.beigeDark.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '${ayah.numberInSurah}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isPlaying ? Colors.white : AppColors.primaryDark,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18, color: AppColors.textSecondary),
                        tooltip: 'نسخ الآية',
                        onPressed: () => _copyAyah(ayah),
                      ),
                      IconButton(
                        icon: Icon(
                          isPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                          size: 24,
                          color: isPlaying ? AppColors.emerald : AppColors.primary,
                        ),
                        tooltip: 'استماع للآية',
                        onPressed: () {
                          if (isPlaying) {
                            _audioService.pause();
                          } else {
                            _playSpecificAyah(ayah.numberInSurah);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                displayText,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: GoogleFonts.amiri(
                  fontSize: _fontSize,
                  height: 2.0,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              if (ayah.sajda) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'سجدة تلاوة',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.brown),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildSurahHeaderCard(SurahFullModel fullSurah) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.emerald],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            fullSurah.nameArabic,
            style: GoogleFonts.amiri(
              color: AppColors.textOnPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fullSurah.englishName,
            style: const TextStyle(
              color: AppColors.goldLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildHeaderMeta('ترتيبها', '${_currentSurah.number}'),
              _buildHeaderMeta('مكان النزول', _currentSurah.revelationTypeArabic),
              _buildHeaderMeta('عدد آياتها', '${_currentSurah.ayahCount}'),
              _buildHeaderMeta('الصفحة', '${_currentSurah.startPage}'),
              if (fullSurah.ayahs.isNotEmpty)
                _buildHeaderMeta('الجزء', '${fullSurah.ayahs.first.juz}'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderMeta(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textOnPrimary,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.goldLight,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildBasmalaBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            fontSize: _fontSize + 2,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildEndOfSurahBadge() {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.emerald.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, color: AppColors.emerald, size: 18),
            const SizedBox(width: 8),
            Text(
              'نهاية سورة ${_currentSurah.nameArabic}',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Live Audio Player Bar (using QuranAudioService)
  Widget _buildAudioPlayerBar() {
    final currentReciter = _audioService.selectedReciter;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.beigeDark.withValues(alpha: 0.6))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Reciter Selection Dropdown
            InkWell(
              onTap: _showReciterPicker,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.record_voice_over_outlined, size: 16, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      currentReciter.nameArabic,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down, color: AppColors.primaryDark, size: 18),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),

            // Controls Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => LogReadingDialog(initialSurahNumber: _currentSurah.number),
                    );
                  },
                  icon: const Icon(Icons.add_task_rounded, size: 16),
                  label: const Text('تسجيل الورد', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),

                // Playback Navigation & Live Audio Controls
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: AppColors.primary),
                      tooltip: 'الآية السابقة',
                      onPressed: () => _audioService.previousAyah(),
                    ),
                    InkWell(
                      onTap: _togglePlayPause,
                      customBorder: const CircleBorder(),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: AppColors.emerald,
                          shape: BoxShape.circle,
                        ),
                        child: _isLoadingAudio
                            ? const SizedBox(
                                width: 26,
                                height: 26,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : Icon(
                                _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 26,
                              ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: AppColors.primary),
                      tooltip: 'الآية التالية',
                      onPressed: () => _audioService.nextAyah(),
                    ),
                  ],
                ),

                // Active Playing Ayah Indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _isPlaying
                        ? AppColors.emerald.withValues(alpha: 0.15)
                        : AppColors.goldLight.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _isPlaying ? AppColors.emerald : Colors.transparent,
                    ),
                  ),
                  child: Text(
                    'الآية $_currentPlayingAyah',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: _isPlaying ? AppColors.emerald : AppColors.primaryDark,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReciterPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Text(
                  'اختر القارئ المفضل',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              ...QuranAudioService.availableReciters.map((r) {
                final isSelected = r.id == _audioService.selectedReciter.id;
                return ListTile(
                  leading: Icon(
                    Icons.mic_none_rounded,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(
                    r.nameArabic,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.emerald)
                      : null,
                  onTap: () {
                    _audioService.setReciter(r);
                    setState(() {});
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }

  void _showFontSizeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Text('تغيير حجم خط المصحف'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                    style: GoogleFonts.amiri(fontSize: _fontSize, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Slider(
                    value: _fontSize,
                    min: 16.0,
                    max: 34.0,
                    divisions: 9,
                    activeColor: AppColors.primary,
                    label: '${_fontSize.toInt()}',
                    onChanged: (val) {
                      setDialogState(() => _fontSize = val);
                      setState(() => _fontSize = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('تم'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAyahActionSheet(AyahModel ayah) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isThisPlaying = _isPlaying && ayah.numberInSurah == _currentPlayingAyah;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'سورة ${_currentSurah.nameArabic} — الآية ${ayah.numberInSurah}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: Icon(
                    isThisPlaying ? Icons.pause_circle_filled : Icons.play_circle_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(isThisPlaying ? 'إيقاف التلاوة' : 'استماع إلى هذه الآية بصوت ${_audioService.selectedReciter.nameArabic}'),
                  onTap: () {
                    Navigator.pop(context);
                    if (isThisPlaying) {
                      _audioService.pause();
                    } else {
                      _playSpecificAyah(ayah.numberInSurah);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.bookmark_add_outlined, color: AppColors.goldDark),
                  title: const Text('حفظ كعلامة توقف'),
                  onTap: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    Navigator.pop(context);
                    await ref.read(quranActionsProvider).updateLastPosition(
                      surahNumber: _currentSurah.number,
                      surahName: _currentSurah.nameArabic,
                      ayahNumber: ayah.numberInSurah,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('تم حفظ الآية ${ayah.numberInSurah} كعلامة توقف'),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.copy_rounded, color: AppColors.textPrimary),
                  title: const Text('نسخ الآية'),
                  onTap: () {
                    Navigator.pop(context);
                    _copyAyah(ayah);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyAyah(AyahModel ayah) {
    final text = '${ayah.getUthmaniTextForSurah(_currentSurah.number)} ﴿${ayah.numberInSurah}﴾ [سورة ${_currentSurah.nameArabic}]';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الآية الكريمة إلى الحافظة'),
        backgroundColor: AppColors.primary,
        duration: Duration(seconds: 2),
      ),
    );
  }
}
