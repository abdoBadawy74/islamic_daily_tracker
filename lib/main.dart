import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:islamic_daily_tracker/core/theme/app_theme.dart';
import 'package:islamic_daily_tracker/data/datasources/local/database_helper.dart';
import 'package:islamic_daily_tracker/navigation/main_shell.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SQLite Database and seed default authentic data
  final dbHelper = DatabaseHelper();
  await dbHelper.database;

  runApp(
    const ProviderScope(
      child: IslamicDailyTrackerApp(),
    ),
  );
}

class IslamicDailyTrackerApp extends StatelessWidget {
  const IslamicDailyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'متابع العبادات اليومية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'),
        Locale('ar', ''),
        Locale('en', ''),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox(),
        );
      },
      home: const MainShell(),
    );
  }
}
