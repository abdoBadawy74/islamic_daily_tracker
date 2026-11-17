import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/quran/data/surah_data.dart';
import 'package:islamic_daily_tracker/features/quran/presentation/widgets/log_reading_dialog.dart';
import 'package:islamic_daily_tracker/features/quran/providers/quran_providers.dart';

class SurahDetailScreen extends ConsumerWidget {
  final SurahInfo surah;

  const SurahDetailScreen({super.key, required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actions = ref.read(quranActionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${surah.nameArabic}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark_add_outlined),
            tooltip: 'حفظ كآخر موضع قراءة',
            onPressed: () async {
              await actions.updateLastPosition(
                surahNumber: surah.number,
                surahName: surah.nameArabic,
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حفظ سورة ${surah.nameArabic} كآخر موضع قراءة'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'تسجيل ورد قراءة',
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => LogReadingDialog(initialSurahNumber: surah.number),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Surah Header Card
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.emerald],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    'سُورَةُ ${surah.nameArabic}',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    surah.nameEnglish,
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildHeaderMeta('رقم السورة', '${surah.number}'),
                      _buildHeaderMeta('مكان النزول', surah.revelationTypeArabic),
                      _buildHeaderMeta('عدد الآيات', '${surah.ayahCount}'),
                      _buildHeaderMeta('صفحة المصحف', '${surah.startPage}'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Basmala (except for At-Tawbah)
            if (surah.number != 9)
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // Authentic Source Disclaimer & Integration Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.verified_outlined, color: AppColors.goldDark, size: 36),
                  const SizedBox(height: 10),
                  const Text(
                    'طبقة عرض الآيات الكريمة',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'حرصًا على صيانة كتاب الله وعصمته من أي خطأ مطبعي، تم تجهيز بنية التطبيق لاستقبال نصوص القرآن الكريم كاملة برسم المصحف العثماني من مصدر موثوق (مثل مجمع الملك فهد لطباعة المصحف الشريف أو Quran.com API) في التحديث القادم دون أي محتوى تجريبي.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) => LogReadingDialog(initialSurahNumber: surah.number),
                      );
                    },
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('تسجيل قراءة هذه السورة في الورد اليومي'),
                  ),
                ],
              ),
            ),
          ],
        ),
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
            fontSize: 16,
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
}
