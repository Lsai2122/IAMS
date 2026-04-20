import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/dashboard/student_dashboard.dart';
import 'controllers/academic_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const IAMSApp());
}

final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

class IAMSApp extends StatefulWidget {
  const IAMSApp({super.key});

  @override
  State<IAMSApp> createState() => _IAMSAppState();
}

class _IAMSAppState extends State<IAMSApp> {
  Widget? _initialHome;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final sessionId = prefs.getString('session_id');
    
    if (sessionId != null) {
      final success = await academicController.loginWithSession(sessionId, context);
      if (success) {
        setState(() {
          _initialHome = const MainNavigationScreen(
            dashboard: StudentDashboard(),
            role: 'Student',
          );
        });
        return;
      }
    }
    
    setState(() {
      _initialHome = const LoginScreen();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialHome == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          title: 'IAMS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          home: _initialHome,
        );
      },
    );
  }
}
