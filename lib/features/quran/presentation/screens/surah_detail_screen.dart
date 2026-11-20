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

class SurahDetailScreen extends ConsumerStatefulWidget {
  final SurahInfo surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  ConsumerState<SurahDetailScreen> createState() => _SurahDetailScreenState();
}

class _SurahDetailScreenState extends ConsumerState<SurahDetailScreen> {
  late SurahInfo _currentSurah;
  late int _currentPage;
  late PageController _pageController;

  double _fontSize = 21.0;
  bool _showOverlay = true;

  final QuranAudioService _audioService = QuranAudioService();
  bool _isPlaying = false;
  bool _isLoadingAudio = false;
  int _currentPlayingAyah = 1;

  @override
  void initState() {
    super.initState();
    _currentSurah = widget.surah;
    _currentPage = widget.surah.startPage;
    _pageController = PageController(initialPage: _currentPage - 1);

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
    _pageController.dispose();
    super.dispose();
  }

  void _switchSurah(SurahInfo newSurah) {
    _audioService.stop();
    setState(() {
      _currentSurah = newSurah;
      _currentPlayingAyah = 1;
      _isPlaying = false;
      _currentPage = newSurah.startPage;
    });
    if (_pageController.hasClients) {
      _pageController.jumpToPage(newSurah.startPage - 1);
    }
  }

  void _goToPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > 604) return;
    final targetIndex = pageNumber - 1;
    if (_pageController.hasClients) {
      _pageController.animateToPage(
        targetIndex,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
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

  static String _toArabicDigits(int number) {
    const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
    return number.toString().split('').map((c) => digits[int.parse(c)]).join();
  }

  static String _getJuzArabicName(int juz) {
    const juzNames = [
      'الأول', 'الثاني', 'الثالث', 'الرابع', 'الخامس',
      'السادس', 'السابع', 'الثامن', 'التاسع', 'العاشر',
      'الحادي عشر', 'الثاني عشر', 'الثالث عشر', 'الرابع عشر', 'الخامس عشر',
      'السادس عشر', 'السابع عشر', 'الثامن عشر', 'التاسع عشر', 'العشرون',
      'الحادي والعشرون', 'الثاني والعشرون', 'الثالث والعشرون', 'الرابع والعشرون', 'الخامس والعشرون',
      'السادس والعشرون', 'السابع والعشرون', 'الثامن والعشرون', 'التاسع والعشرون', 'الثلاثون',
    ];
    if (juz >= 1 && juz <= 30) return juzNames[juz - 1];
    return _toArabicDigits(juz);
  }

  @override
  Widget build(BuildContext context) {
    final actions = ref.read(quranActionsProvider);
    final allPagesAsync = ref.watch(allQuranPagesProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7EE), // Authentic Medina cream paper
      body: Stack(
        children: [
          // 1. Full Screen Medina Mushaf PageView
          allPagesAsync.when(
            data: (pagesMap) {
              return Directionality(
                textDirection: TextDirection.rtl, // RTL: Drag right-to-left flips to next page!
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: 604,
                  onPageChanged: (index) {
                    final pageNum = index + 1;
                    setState(() {
                      _currentPage = pageNum;
                      // Update active Surah matching this page
                      _currentSurah = QuranData.surahs.lastWhere(
                        (s) => s.startPage <= pageNum,
                        orElse: () => QuranData.surahs.first,
                      );
                    });
                  },
                  itemBuilder: (context, index) {
                    final pageNumber = index + 1;
                    final pageAyahs = pagesMap[pageNumber] ?? [];
                    return _buildFullMushafPaperPage(pageNumber, pageAyahs);
                  },
                ),
              );
            },
            loading: () => const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text(
                    'جاري فتح المصحف الشريف...',
                    style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            error: (err, _) => Center(child: Text('خطأ في تحميل المصحف: $err')),
          ),

          // 2. Floating Top AppBar (Visible when _showOverlay is true)
          if (_showOverlay)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _buildTopOverlayBar(actions),
            ),

          // 3. Floating Bottom Controls & Page Navigation (Visible when _showOverlay is true)
          if (_showOverlay)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomOverlayBar(),
            ),
        ],
      ),
    );
  }

  // Authentic Medina Mushaf Paper Page
  Widget _buildFullMushafPaperPage(int pageNumber, List<MushafAyahItem> pageAyahs) {
    final int juz = pageAyahs.isNotEmpty ? pageAyahs.first.ayah.juz : 1;
    final String surahName = pageAyahs.isNotEmpty ? pageAyahs.first.surahName : _currentSurah.nameArabic;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() => _showOverlay = !_showOverlay);
      },
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFDF8),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC5A059), width: 1.8), // Outer gold frame
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2C2416).withValues(alpha: 0.08),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Container(
            margin: const EdgeInsets.all(3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDEC38B), width: 0.8), // Inner gold frame
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Page Header (Surah name right, star center, Juz left)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E7D3).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'سُورَةُ $surahName',
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7A5813),
                        ),
                      ),
                    ),
                    const Text(
                      '۞',
                      style: TextStyle(fontSize: 14, color: Color(0xFFC5A059), fontWeight: FontWeight.bold),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2E7D3).withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        'الجُزْءُ ${_getJuzArabicName(juz)}',
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF7A5813),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Divider(height: 1, color: Color(0xFFE5D5B8), thickness: 0.9),
                const SizedBox(height: 6),

                // Main Quran Text filling the whole page height & width!
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: _buildPageAyahsContent(pageAyahs),
                  ),
                ),

                const SizedBox(height: 4),
                const Divider(height: 1, color: Color(0xFFE5D5B8), thickness: 0.9),
                const SizedBox(height: 4),

                // Bottom Page Footer (Centered Arabic Page Number)
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3E9D7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.5)),
                    ),
                    child: Text(
                      '— ${_toArabicDigits(pageNumber)} —',
                      style: GoogleFonts.amiri(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF7A5813),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Renders the ayahs on a page, showing Surah & Basmala banners if a Surah begins on this page
  Widget _buildPageAyahsContent(List<MushafAyahItem> pageAyahs) {
    if (pageAyahs.isEmpty) {
      return const SizedBox.shrink();
    }

    final List<Widget> widgets = [];
    List<MushafAyahItem> currentSegment = [];
    int? currentSegmentSurahNum;

    void flushSegment() {
      if (currentSegment.isEmpty) return;
      widgets.add(
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: RichText(
            textAlign: TextAlign.justify,
            textDirection: TextDirection.rtl,
            text: TextSpan(
              style: GoogleFonts.amiri(
                fontSize: _fontSize,
                height: 2.25,
                color: const Color(0xFF1A1816), // Calligraphy black ink
                letterSpacing: 0,
              ),
              children: currentSegment.map((item) {
                final ayah = item.ayah;
                final displayText = ayah.getUthmaniTextForSurah(item.surahNumber);
                final isPlaying = _isPlaying &&
                    item.surahNumber == _currentSurah.number &&
                    ayah.numberInSurah == _currentPlayingAyah;
                final arabicNum = _toArabicDigits(ayah.numberInSurah);

                return TextSpan(
                  children: [
                    TextSpan(
                      text: '$displayText ',
                      style: TextStyle(
                        backgroundColor: isPlaying
                            ? AppColors.emerald.withValues(alpha: 0.22)
                            : Colors.transparent,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showAyahActionSheet(ayah, item.surahNumber, item.surahName),
                    ),
                    TextSpan(
                      text: ' ﴿$arabicNum﴾ ',
                      style: TextStyle(
                        fontSize: _fontSize * 0.8,
                        fontWeight: FontWeight.bold,
                        color: isPlaying ? AppColors.emerald : const Color(0xFF9E782F),
                        backgroundColor: isPlaying
                            ? AppColors.emerald.withValues(alpha: 0.22)
                            : Colors.transparent,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => _showAyahActionSheet(ayah, item.surahNumber, item.surahName),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ),
      );
      currentSegment = [];
    }

    for (final item in pageAyahs) {
      // If a Surah starts on this page (first ayah in surah)
      if (item.ayah.numberInSurah == 1) {
        flushSegment();

        final sInfo = QuranData.surahs.firstWhere(
          (s) => s.number == item.surahNumber,
          orElse: () => _currentSurah,
        );

        // 1. Ornate Medina Surah Title Header Frame
        widgets.add(_buildSurahPlaque(sInfo));
        widgets.add(const SizedBox(height: 6));

        // 2. Centered Basmala (except Surah 9 At-Tawbah)
        if (item.surahNumber != 9) {
          widgets.add(_buildBasmalaPlaque());
          widgets.add(const SizedBox(height: 6));
        }

        currentSegmentSurahNum = item.surahNumber;
      } else if (currentSegmentSurahNum != null && currentSegmentSurahNum != item.surahNumber) {
        flushSegment();
        currentSegmentSurahNum = item.surahNumber;
      }

      currentSegment.add(item);
    }

    flushSegment();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }

  // Authentic Medina Mushaf Surah Header Plaque
  Widget _buildSurahPlaque(SurahInfo surah) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFF133E2B), // Authentic Medina Emerald
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC5A059), width: 1.6),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE2CCA2), width: 0.9),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('۞ ', style: TextStyle(color: Color(0xFFE2CCA2), fontSize: 14)),
                Text(
                  'سُورَةُ ${surah.nameArabic}',
                  style: GoogleFonts.amiri(
                    color: const Color(0xFFFFF9EE),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                const Text(' ۞', style: TextStyle(color: Color(0xFFE2CCA2), fontSize: 14)),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              '${surah.revelationTypeArabic} — آيَاتُهَا ${_toArabicDigits(surah.ayahCount)} — تَرْتِيبُهَا ${_toArabicDigits(surah.number)}',
              style: GoogleFonts.amiri(
                color: const Color(0xFFE5D5B8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Basmala Plaque
  Widget _buildBasmalaPlaque() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8EE),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC5A059).withValues(alpha: 0.7), width: 1),
      ),
      child: Center(
        child: Text(
          'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
          textAlign: TextAlign.center,
          style: GoogleFonts.amiri(
            fontSize: _fontSize + 1,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF163E2B),
          ),
        ),
      ),
    );
  }

  // Top Overlay AppBar
  Widget _buildTopOverlayBar(QuranActions actions) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryDark.withValues(alpha: 0.95),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.goldLight),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: _buildSurahSelector(),
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
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ صفحة $_currentPage (سورة ${_currentSurah.nameArabic}) كآخر قراءة'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // Bottom Overlay Bar (Slider, Quick Paging & Audio)
  Widget _buildBottomOverlayBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        border: Border(top: BorderSide(color: AppColors.gold.withValues(alpha: 0.4))),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -3))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Page Navigation Slider
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.primary),
                    tooltip: 'الصفحة السابقة',
                    onPressed: () => _goToPage(_currentPage - 1),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          'صفحة ${_toArabicDigits(_currentPage)} من ٦٠٤',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 3.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                          ),
                          child: Slider(
                            value: _currentPage.toDouble(),
                            min: 1.0,
                            max: 604.0,
                            activeColor: AppColors.primary,
                            inactiveColor: AppColors.beigeDark,
                            onChanged: (val) {
                              _goToPage(val.toInt());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_rounded, size: 18, color: AppColors.primary),
                    tooltip: 'الصفحة التالية',
                    onPressed: () => _goToPage(_currentPage + 1),
                  ),
                ],
              ),

              // Audio Controls & Log Reading Button
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),

                  // Audio Playback
                  Row(
                    children: [
                      InkWell(
                        onTap: _showReciterPicker,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          child: Row(
                            children: [
                              const Icon(Icons.mic_none_rounded, size: 16, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                _audioService.selectedReciter.nameArabic,
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.skip_previous_rounded, color: AppColors.primary),
                        tooltip: 'الآية السابقة',
                        onPressed: () => _audioService.previousAyah(),
                      ),
                      InkWell(
                        onTap: _togglePlayPause,
                        customBorder: const CircleBorder(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.emerald,
                            shape: BoxShape.circle,
                          ),
                          child: _isLoadingAudio
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 22,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Surah Selector Dropdown in AppBar
  Widget _buildSurahSelector() {
    return PopupMenuButton<SurahInfo>(
      initialValue: _currentSurah,
      tooltip: 'اختر السورة',
      onSelected: _switchSurah,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'سورة ${_currentSurah.nameArabic}',
              style: const TextStyle(
                color: AppColors.goldLight,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const Icon(Icons.arrow_drop_down, color: AppColors.goldLight),
          ],
        ),
      ),
      itemBuilder: (context) {
        return QuranData.surahs.map((s) {
          return PopupMenuItem<SurahInfo>(
            value: s,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${s.number}. ${s.nameArabic}'),
                Text(
                  'صفحة ${s.startPage}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          );
        }).toList();
      },
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
                    max: 32.0,
                    divisions: 8,
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

  void _showAyahActionSheet(AyahModel ayah, int surahNumber, String surahName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final isThisPlaying = _isPlaying &&
            surahNumber == _currentSurah.number &&
            ayah.numberInSurah == _currentPlayingAyah;

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
                  'سورة $surahName — الآية ${ayah.numberInSurah}',
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
                      surahNumber: surahNumber,
                      surahName: surahName,
                      ayahNumber: ayah.numberInSurah,
                    );
                    if (!mounted) return;
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text('تم حفظ الآية ${ayah.numberInSurah} من سورة $surahName كعلامة توقف'),
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
                    _copyAyah(ayah, surahNumber, surahName);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _copyAyah(AyahModel ayah, int surahNumber, String surahName) {
    final text = '${ayah.getUthmaniTextForSurah(surahNumber)} ﴿${ayah.numberInSurah}﴾ [سورة $surahName]';
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
