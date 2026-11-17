import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_colors.dart';
import 'package:islamic_daily_tracker/features/azkar/presentation/screens/azkar_screen.dart';
import 'package:islamic_daily_tracker/features/home/presentation/screens/home_screen.dart';
import 'package:islamic_daily_tracker/features/quran/presentation/screens/quran_screen.dart';
import 'package:islamic_daily_tracker/features/statistics/presentation/screens/statistics_screen.dart';
import 'package:islamic_daily_tracker/features/worship/presentation/screens/worship_screen.dart';

final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

class MainShell extends ConsumerWidget {
  const MainShell({super.key});

  static const List<Widget> _screens = [
    HomeScreen(),
    WorshipScreen(),
    QuranScreen(),
    AzkarScreen(),
    StatisticsScreen(),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.checklist_rtl_outlined),
              activeIcon: Icon(Icons.checklist_rtl_rounded),
              label: 'العبادات',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'القرآن',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_outlined),
              activeIcon: Icon(Icons.auto_stories_rounded),
              label: 'الأذكار',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: 'الإحصائيات',
            ),
          ],
        ),
      ),
    );
  }
}
