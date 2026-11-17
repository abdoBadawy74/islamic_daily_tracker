import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class StreakBannerWidget extends ConsumerWidget {
  const StreakBannerWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(consecutiveDaysStreakProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.emerald],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row with streak
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.local_fire_department_rounded, color: AppColors.goldLight, size: 20),
                  SizedBox(width: 6),
                  Text(
                    'سلسلة الالتزام بالصلوات',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'يومي',
                  style: TextStyle(color: Colors.white, fontSize: 11),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Streak Count Number (e.g. "5 أيام متتالية")
          streakAsync.when(
            data: (streak) => Text(
              '$streak ${streak == 1 ? "يوم" : "أيام"} التزام متواصل',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
            loading: () => const Text(
              '... أيام',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            error: (e, s) => const Text(
              'ابدأ سلسلتك اليوم!',
              style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // Spiritual Quote (matching screenshot 3)
          const Text(
            '«إِنَّ مَعَ الْعُسْرِ يُسْرًا» — إقبالك على الصلاة بقلبٍ حاضر نورٌ لقلبك وسعةٌ في رزقك وطمأنينةٌ ليومك.',
            style: TextStyle(
              color: AppColors.goldLight,
              fontSize: 12,
              height: 1.5,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}
