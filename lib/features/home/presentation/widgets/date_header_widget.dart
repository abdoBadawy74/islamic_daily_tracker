import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/core/utils/date_utils.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';
import 'package:islamic_daily_tracker/features/settings/presentation/screens/settings_screen.dart';

class DateHeaderWidget extends ConsumerWidget {
  const DateHeaderWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDate = ref.watch(selectedDateProvider);
    final settingsAsync = ref.watch(appSettingsProvider);
    final userName = settingsAsync.value?.userName ?? '';
    final isToday = AppDateUtils.isToday(selectedDate);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 20,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Top Row: Greeting & Settings Icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName.isNotEmpty ? 'السلام عليكم، $userName' : 'السلام عليكم ورحمة الله',
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    '«أَحَبُّ الْأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ»',
                    style: TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                icon: const Icon(Icons.settings_outlined, color: AppColors.textOnPrimary),
                tooltip: 'الإعدادات',
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Date Navigator Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Previous Day
                IconButton(
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.subtract(const Duration(days: 1));
                  },
                  icon: const Icon(Icons.chevron_right, color: AppColors.textOnPrimary, size: 28),
                  tooltip: 'اليوم السابق',
                ),

                // Center Date Info
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            AppDateUtils.getDayName(selectedDate),
                            style: const TextStyle(
                              color: AppColors.gold,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (isToday) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                              decoration: BoxDecoration(
                                color: AppColors.gold,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'اليوم',
                                style: TextStyle(
                                  color: AppColors.primaryDark,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppDateUtils.formatHijriDate(selectedDate),
                        style: const TextStyle(
                          color: AppColors.textOnPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        AppDateUtils.formatGregorianDate(selectedDate),
                        style: TextStyle(
                          color: AppColors.textOnPrimary.withValues(alpha: 0.75),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                // Next Day
                IconButton(
                  onPressed: () {
                    ref.read(selectedDateProvider.notifier).state =
                        selectedDate.add(const Duration(days: 1));
                  },
                  icon: const Icon(Icons.chevron_left, color: AppColors.textOnPrimary, size: 28),
                  tooltip: 'اليوم التالي',
                ),
              ],
            ),
          ),

          // Return to today button if not today
          if (!isToday) ...[
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  ref.read(selectedDateProvider.notifier).state =
                      AppDateUtils.getDateOnly(DateTime.now());
                },
                icon: const Icon(Icons.today, size: 16, color: AppColors.goldLight),
                label: const Text(
                  'العودة لليوم الحالي',
                  style: TextStyle(color: AppColors.goldLight, fontSize: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
