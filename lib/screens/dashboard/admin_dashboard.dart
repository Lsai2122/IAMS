import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../login_screen.dart';
import '../users/manage_users_screen.dart';
import '../courses/courses_screen.dart';
import '../events/events_screen.dart';
import '../grievance/admin_query_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
              'System Administrator',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Main Campus Management',
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
                  icon: Icons.people_outline_rounded,
                  label: 'Manage Users',
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageUsersScreen())),
                ),
                DashboardCard(
                  icon: Icons.book_outlined,
                  label: 'Manage Courses',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CoursesScreen())),
                ),
                DashboardCard(
                  icon: Icons.event_note_outlined,
                  label: 'Events Control',
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen())),
                ),
                DashboardCard(
                  icon: Icons.help_center_outlined,
                  label: 'Grievances',
                  color: Colors.red,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminQueryScreen())),
                ),
                DashboardCard(
                  icon: Icons.analytics_outlined,
                  label: 'Reports',
                  color: Colors.orange,
                  onTap: () {},
                ),
                DashboardCard(
                  icon: Icons.settings_outlined,
                  label: 'System Settings',
                  color: Colors.grey,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
