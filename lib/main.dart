import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/dashboard/student_dashboard.dart';

void main() {
  runApp(const IAMSApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class IAMSApp extends StatelessWidget {
  const IAMSApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'IAMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          // Directly opening the main navigation screen as requested
          home: const MainNavigationScreen(
            dashboard: StudentDashboard(),
            role: 'Student',
          ),
        );
      },
    );
  }
}
