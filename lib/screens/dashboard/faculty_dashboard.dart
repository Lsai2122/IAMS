import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../login_screen.dart';
import '../courses/courses_screen.dart';
import '../attendance/attendance_screen.dart';
import '../grades/grades_screen.dart';
import '../materials/materials_screen.dart';
import '../notifications/notifications_screen.dart';

class FacultyDashboard extends StatelessWidget {
  const FacultyDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Faculty Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome, Dr. Smith!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Senior Professor • Dept. of CSE',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  icon: Icons.book_outlined,
                  label: 'My Courses',
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen())),
                ),
                DashboardCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Attendance',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AttendanceScreen())),
                ),
                DashboardCard(
                  icon: Icons.grade_outlined,
                  label: 'Enter Grades',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GradesScreen())),
                ),
                DashboardCard(
                  icon: Icons.upload_file_outlined,
                  label: 'Upload Materials',
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MaterialsScreen())),
                ),
                DashboardCard(
                  icon: Icons.announcement_outlined,
                  label: 'Announcements',
                  color: Colors.red,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
