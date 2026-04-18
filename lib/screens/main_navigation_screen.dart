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
import 'events/create_event_screen.dart';
import 'events/participants_screen.dart';
import 'events/engagement_screen.dart';
import 'events/event_notices_screen.dart';
import 'events/event_inbox_screen.dart';
import 'faculty/faculty_assignments_screen.dart';
import 'faculty/create_assignment_screen.dart';
import 'grievance/anonymous_query_screen.dart';
import 'dashboard/student_dashboard.dart';
import 'dashboard/event_coordinator_dashboard.dart';
import 'dashboard/faculty_dashboard.dart';
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
  int _sideMenuIndex = 0;
  double _sliderYOffset = -80; 

  // Side Ball icons per Role
  final List<IconData> _studentIcons = [
    Icons.dashboard_rounded,
    Icons.book_rounded,
    Icons.grade_rounded,
    Icons.calendar_month_rounded,
    Icons.event_rounded,
    Icons.schedule_rounded,
    Icons.help_center_rounded,
  ];

  final List<IconData> _eventIcons = [
    Icons.dashboard_rounded,
    Icons.add_circle_rounded,
    Icons.event_note_rounded,
    Icons.people_rounded,
    Icons.analytics_rounded,
  ];

  final List<IconData> _facultyIcons = [
    Icons.dashboard_rounded,
    Icons.assignment_rounded,
    Icons.how_to_reg_rounded, // Attendance marking
    Icons.grade_rounded,
    Icons.upload_file_rounded,
    Icons.campaign_rounded,
  ];

  late List<Widget> _sideMenuScreens;
  late List<Widget> _bottomBarScreens;

  @override
  void initState() {
    super.initState();
    
    if (widget.role == 'Event Coordinator') {
      _sideMenuScreens = [
        const EventCoordinatorDashboard(),
        const CreateEventScreen(),
        const EventsScreen(),
        const ParticipantsScreen(),
        const EngagementScreen(),
      ];
      
      _bottomBarScreens = [
        const SizedBox.shrink(), // Dynamic Side Menu Tab
        const EventNoticesScreen(),
        const EventInboxScreen(),
        _SettingsScreen(role: widget.role),
      ];
    } else if (widget.role == 'Faculty') {
      _sideMenuScreens = [
        const FacultyDashboard(),
        const FacultyAssignmentsScreen(),
        const AttendanceScreen(), // Faculty can mark attendance here
        const GradesScreen(),
        const MaterialsScreen(),
        const EventNoticesScreen(),
      ];

      _bottomBarScreens = [
        const SizedBox.shrink(),
        const FacultyAssignmentsScreen(),
        const NotificationsScreen(),
        _SettingsScreen(role: widget.role),
      ];
    } else {
      _sideMenuScreens = [
        const StudentDashboard(),
        const CoursesScreen(),
        const GradesScreen(),
        const AttendanceScreen(),
        const EventsScreen(),
        const TimetableScreen(),
        const AnonymousQueryScreen(),
      ];
      
      _bottomBarScreens = [
        const SizedBox.shrink(), 
        const MaterialsScreen(),
        const NotificationsScreen(),
        _SettingsScreen(role: widget.role),
      ];
    }
  }

  void _onSideMenuAction(int index) {
    setState(() {
      _bottomNavIndex = 0;
      _sideMenuIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget activeBody = _bottomNavIndex == 0 ? _sideMenuScreens[_sideMenuIndex] : _bottomBarScreens[_bottomNavIndex];
    List<IconData> currentIcons;
    if (widget.role == 'Event Coordinator') {
      currentIcons = _eventIcons;
    } else if (widget.role == 'Faculty') {
      currentIcons = _facultyIcons;
    } else {
      currentIcons = _studentIcons;
    }

    return Scaffold(
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
                children: _getBottomNavItems(),
              ),
            ),
          ),

          // Role-specific Floating Action Button (Student only)
          if (widget.role == 'Student')
            Positioned(
              bottom: 12,
              left: MediaQuery.of(context).size.width / 2 - 29,
              child: SizedBox(
                width: 58, height: 60,
                child: FloatingActionButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceStatsScreen())),
                  shape: const CircleBorder(),
                  child: Container(
                    width: 58, height: 58,
                    decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGradient),
                    child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 26),
                  ),
                ),
              ),
            ),

          // RELOCATABLE SIDE BALL
          Positioned(
            right: 0,
            top: (MediaQuery.of(context).size.height / 2) - 30 + _sliderYOffset,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                setState(() {
                  _sliderYOffset += details.delta.dy;
                  double limit = (MediaQuery.of(context).size.height / 2) - 100;
                  if (_sliderYOffset > limit) _sliderYOffset = limit;
                  if (_sliderYOffset < -limit) _sliderYOffset = -limit;
                });
              },
              child: SmartWatchSlider(
                selectedIndex: _bottomNavIndex == 0 ? _sideMenuIndex : -1,
                icons: currentIcons,
                onPageChanged: _onSideMenuAction,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getBottomNavItems() {
    if (widget.role == 'Event Coordinator') {
      return [
        _bottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
        _bottomNavItem(1, Icons.campaign_rounded, Icons.campaign_outlined, 'Notice'),
        _bottomNavItem(2, Icons.mail_rounded, Icons.mail_outlined, 'Inbox'),
        _bottomNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
      ];
    } else if (widget.role == 'Faculty') {
      return [
        _bottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
        _bottomNavItem(1, Icons.assignment_rounded, Icons.assignment_outlined, 'Tasks'),
        _bottomNavItem(2, Icons.notifications_rounded, Icons.notifications_none_rounded, 'Updates'),
        _bottomNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
      ];
    } else {
      return [
        _bottomNavItem(0, Icons.home_rounded, Icons.home_outlined, 'Home'),
        _bottomNavItem(1, Icons.folder_rounded, Icons.folder_open_outlined, 'Library'),
        const SizedBox(width: 48), 
        _bottomNavItem(2, Icons.notifications_rounded, Icons.notifications_none_rounded, 'Updates'),
        _bottomNavItem(3, Icons.settings_rounded, Icons.settings_outlined, 'Settings'),
      ];
    }
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
                  const Text('User Profile', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
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
