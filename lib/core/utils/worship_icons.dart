import 'package:flutter/material.dart';

class WorshipIcons {
  WorshipIcons._();

  static IconData getIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'mosque':
      case 'prayer':
        return Icons.mosque_outlined;
      case 'sun':
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'moon':
      case 'taraweeh':
        return Icons.nightlight_round_outlined;
      case 'fasting':
        return Icons.restaurant_menu_outlined;
      case 'quran':
      case 'book':
      case 'tafsir':
        return Icons.menu_book_rounded;
      case 'sunset':
        return Icons.wb_twilight_rounded;
      case 'sleep':
        return Icons.bedtime_outlined;
      case 'hands':
      case 'dua':
        return Icons.volunteer_activism_outlined;
      case 'heart':
      case 'dhikr':
        return Icons.favorite_border_rounded;
      case 'charity':
        return Icons.handshake_outlined;
      case 'secret':
        return Icons.visibility_off_outlined;
      case 'clock':
        return Icons.access_time_rounded;
      case 'review':
        return Icons.fact_check_outlined;
      case 'wakeup':
        return Icons.alarm_rounded;
      default:
        return Icons.star_border_rounded;
    }
  }

  static Color getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'prayer':
        return const Color(0xFF2E7D32);
      case 'fasting':
        return const Color(0xFFE65100);
      case 'quran':
        return const Color(0xFF00897B);
      case 'azkar':
      case 'dhikr':
        return const Color(0xFFD4A843);
      case 'charity':
        return const Color(0xFF1E88E5);
      case 'knowledge':
        return const Color(0xFF8E24AA);
      default:
        return const Color(0xFF546E7A);
    }
  }

  static String getCategoryArabicName(String category) {
    switch (category.toLowerCase()) {
      case 'prayer':
        return 'الصلاة والسنن';
      case 'fasting':
        return 'الصيام';
      case 'quran':
        return 'القرآن الكريم';
      case 'azkar':
      case 'dhikr':
        return 'الأذكار والتسبيح';
      case 'charity':
        return 'الصدقة والإنفاق';
      case 'knowledge':
        return 'العلم والتدبر';
      case 'dua':
        return 'الدعاء';
      default:
        return 'عادات إيمانية';
    }
  }
}
