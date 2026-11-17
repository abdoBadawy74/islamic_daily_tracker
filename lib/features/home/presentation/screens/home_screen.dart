import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/date_header_widget.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/daily_progress_widget.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/prayer_tracker_widget.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/quick_stats_shortcuts_widget.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/streak_banner_widget.dart';
import 'package:islamic_daily_tracker/features/home/presentation/widgets/worship_summary_widget.dart';
import 'package:islamic_daily_tracker/features/home/providers/home_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(dailyPrayersProvider);
          ref.invalidate(activeWorshipsProvider);
          ref.invalidate(dailyRecordsProvider);
          ref.invalidate(consecutiveDaysStreakProvider);
        },
        child: const SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with Hijri/Gregorian date and navigation
              DateHeaderWidget(),

              SizedBox(height: 6),

              // Streak & Inspirational Quote Banner (matching Screenshot 3)
              StreakBannerWidget(),

              // Quick Stats / Shortcuts (Prayer, Quran, Tasbih) (matching Screenshot 3)
              QuickStatsShortcutsWidget(),

              SizedBox(height: 6),

              // Overall Daily Progress Card
              DailyProgressWidget(),

              // Prayer Tracker Card (5 Daily Prayers with onTime/late/missed/none)
              PrayerTrackerWidget(),

              // Worship Checklist Summary
              WorshipSummaryWidget(),

              SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
