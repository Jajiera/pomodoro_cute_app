import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pomodoro_cute_app/utils/constants.dart';
import 'package:pomodoro_cute_app/screens/pomodoro_screen.dart';

void main() {
  runApp(const PomodoroCuteApp());
}

class PomodoroCuteApp extends StatelessWidget {
  const PomodoroCuteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<AppThemeMode>(
      valueListenable: AppColors.currentTheme,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'Cute Pomodoro',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.primary,
              surface: AppColors.background,
            ),
            scaffoldBackgroundColor: AppColors.background,
            textTheme: GoogleFonts.nunitoTextTheme(
              Theme.of(context).textTheme,
            ).apply(
              bodyColor: AppColors.textDark,
              displayColor: AppColors.textDark,
            ),
            useMaterial3: true,
          ),
          home: const PomodoroScreen(),
        );
      },
    );
  }
}
