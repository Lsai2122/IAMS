import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/smart_watch_slider.dart';
import '../main.dart'; // To access themeNotifier
import 'notifications/notifications_screen.dart';
import 'materials/materials_screen.dart';
import 'courses/courses_screen.dart';
import 'grades/grades_screen.dart';
import 'attendance/attendance_screen.dart';
import 'attendance/attendance_stats_screen.dart';
import 'events/events_screen.dart';
import 'grievance/anonymous_query_screen.dart';
import 'dashboard/student_dashboard.dart';
import 'timetable/timetable_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final Widget dashboard;
  final String role;

  const MainNavigationScreen({
    super.key,
    required this.dashboard,
    required this.role,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _bottomNavIndex = 0;
  int _academicIndex = 0;
  double _sliderYOffset = -80; // Adjusted initial position to be higher

  final List<IconData> _academicIcons = [
    Icons.dashboard_rounded,
    Icons.book_rounded,
    Icons.grade_rounded,
    Icons.calendar_month_rounded,
    Icons.event_rounded,
    Icons.schedule_rounded,
    Icons.help_center_rounded,
  ];

  late List<Widget> _academicScreens;
  late List<Widget> _bottomBarScreens;

  @override
  void initState() {
    super.initState();
    _academicScreens = [
      widget.dashboard,
      const CoursesScreen(),
      const GradesScreen(),
      const AttendanceScreen(),
      const EventsScreen(),
      const TimetableScreen(),
      const AnonymousQueryScreen(),
    ];

    _bottomBarScreens = [
      const SizedBox.shrink(), // Dynamic Academic Tab
      const MaterialsScreen(),
      const NotificationsScreen(),
      _SettingsScreen(role: widget.role),
    ];
  }

  void _onAcademicAction(int index) {
    setState(() {
      _bottomNavIndex = 0;
      _academicIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeBody = _bottomNavIndex == 0 ? _academicScreens[_academicIndex] : _bottomBarScreens[_bottomNavIndex];

    return Scaffold(
      floatingActionButton: Transform.translate(
        offset: const Offset(0, -10),
        child: SizedBox(
          width: 58,
          height: 58,
          child: FloatingActionButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceStatsScreen())),
            shape: const CircleBorder(),
            child: Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
              child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 26),
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      body: Stack(
        children: [
          Scaffold(
            body: activeBody,
            bottomNavigationBar: BottomAppBar(
              padding: EdgeInsets.zero,
              notchMargin: 8,
              shape: const CircularNotchedRectangle(),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _bottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
                  _bottomNavItem(1, Icons.folder_rounded, Icons.folder_open_outlined, 'Library'),
                  const SizedBox(width: 48),
                  _bottomNavItem(2, Icons.notifications_rounded, Icons.notifications_none_rounded, 'Updates'),
                  _bottomNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
                ],
              ),
            ),
          ),

          // RELOCATABLE SIDE BALL
          Positioned(
            right: 0,
            // Calculate Absolute Y position with higher offset
            top: (MediaQuery.of(context).size.height / 2) - 30 + _sliderYOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _sliderYOffset += details.delta.dy;
                  
                  // Boundary checks
                  double limit = (MediaQuery.of(context).size.height / 2) - 100;
                  if (_sliderYOffset > limit) _sliderYOffset = limit;
                  if (_sliderYOffset < -limit) _sliderYOffset = -limit;
                });
              },
              child: SmartWatchSlider(
                selectedIndex: _bottomNavIndex == 0 ? _academicIndex : -1,
                icons: _academicIcons,
                onPageChanged: _onAcademicAction,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bottomNavItem(int index, IconData activeIcon, IconData inactiveIcon, String label) {
    bool isSelected = _bottomNavIndex == index;
    return IconButton(
      onPressed: () => setState(() => _bottomNavIndex = index),
      icon: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isSelected ? activeIcon : inactiveIcon, color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight, size: 22),
          Text(label, style: TextStyle(fontSize: 9, color: isSelected ? AppTheme.primaryBlue : AppTheme.textLight, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _SettingsScreen extends StatelessWidget {
  final String role;
  const _SettingsScreen({required this.role});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, backgroundColor: Colors.white24, child: Icon(Icons.person, size: 35, color: Colors.white)),
                const SizedBox(width: 20),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Rahul Sharma', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text(role, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                ])),
              ],
            ),
          ),
          const SizedBox(height: 32),
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (_, mode, __) {
              return ListTile(
                leading: const Icon(Icons.dark_mode_outlined, color: AppTheme.primaryBlue),
                title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w500)),
                trailing: Switch(value: mode == ThemeMode.dark, onChanged: (val) => themeNotifier.value = val ? ThemeMode.dark : ThemeMode.light),
              );
            },
          ),
          _buildSettingTile(Icons.person_outline, 'Personal Information'),
          _buildSettingTile(Icons.lock_outline, 'Security & Privacy'),
          _buildSettingTile(Icons.notifications_none, 'Notification Preferences'),
          const Divider(height: 40),
          _buildSettingTile(Icons.help_outline, 'Help & Support'),
          TextButton.icon(onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false), icon: const Icon(Icons.logout, color: Colors.red), label: const Text('Logout', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  Widget _buildSettingTile(IconData icon, String title) {
    return ListTile(leading: Icon(icon, color: AppTheme.primaryBlue), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)), trailing: const Icon(Icons.chevron_right, size: 20), onTap: () {});
  }
}
