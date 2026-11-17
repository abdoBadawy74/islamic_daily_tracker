import 'package:intl/intl.dart';
import 'package:hijri/hijri_calendar.dart';

class AppDateUtils {
  AppDateUtils._();

  static const List<String> arabicDayNames = [
    'الإثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
    'الأحد',
  ];

  static const List<String> hijriMonthNames = [
    'محرم',
    'صفر',
    'ربيع الأول',
    'ربيع الثاني',
    'جمادى الأولى',
    'جمادى الآخرة',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذو القعدة',
    'ذو الحجة',
  ];

  static String getDayName(DateTime date) {
    return arabicDayNames[date.weekday - 1];
  }

  static String formatGregorianDate(DateTime date) {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatHijriDate(DateTime date) {
    final hijri = HijriCalendar.fromDate(date);
    final monthName = (hijri.hMonth >= 1 && hijri.hMonth <= 12)
        ? hijriMonthNames[hijri.hMonth - 1]
        : hijri.longMonthName;
    return '${hijri.hDay} $monthName ${hijri.hYear} هـ';
  }

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static DateTime getDateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  static String dateToKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
