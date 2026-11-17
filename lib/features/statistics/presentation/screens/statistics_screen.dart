import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/statistics/presentation/screens/calendar_history_screen.dart';
import 'package:islamic_daily_tracker/features/statistics/presentation/widgets/prayer_stats_chart.dart';
import 'package:islamic_daily_tracker/features/statistics/presentation/widgets/worship_stats_card.dart';
import 'package:islamic_daily_tracker/features/statistics/providers/statistics_providers.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedPeriod = ref.watch(statsPeriodProvider);
    final prayerStatsAsync = ref.watch(prayerStatsProvider);
    final worshipStatsAsync = ref.watch(overallWorshipStatsProvider);

    final periods = [
      {'period': StatsPeriod.today, 'label': 'اليوم'},
      {'period': StatsPeriod.week, 'label': 'آخر 7 أيام'},
      {'period': StatsPeriod.month, 'label': 'آخر 30 يوم'},
      {'period': StatsPeriod.custom, 'label': 'فترة مخصصة'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإحصائيات والتقارير'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            tooltip: 'التقويم وسجل الأيام',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CalendarHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(prayerStatsProvider);
          ref.invalidate(overallWorshipStatsProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period Selector Row
              Container(
                height: 48,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: periods.length,
                  itemBuilder: (context, index) {
                    final item = periods[index];
                    final p = item['period'] as StatsPeriod;
                    final isSelected = selectedPeriod == p;

                    return Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: ChoiceChip(
                        label: Text(item['label'] as String),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 12,
                        ),
                        onSelected: (selected) async {
                          if (selected) {
                            if (p == StatsPeriod.custom) {
                              final picked = await showDateRangePicker(
                                context: context,
                                firstDate: DateTime(2020),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: Theme.of(context).copyWith(
                                      colorScheme: const ColorScheme.light(
                                        primary: AppColors.primary,
                                        onPrimary: Colors.white,
                                        surface: AppColors.surface,
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (picked != null) {
                                ref.read(customDateRangeProvider.notifier).state = picked;
                                ref.read(statsPeriodProvider.notifier).state = p;
                              }
                            } else {
                              ref.read(statsPeriodProvider.notifier).state = p;
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Prayer Stats Card (with Pie Chart)
              prayerStatsAsync.when(
                data: (stats) => PrayerStatsChart(stats: stats),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(child: Text('خطأ: $err')),
              ),

              // Worship Stats (Consistency rankings, Quran, Dhikr totals)
              worshipStatsAsync.when(
                data: (stats) => WorshipStatsCard(stats: stats),
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, _) => Center(child: Text('خطأ: $err')),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
