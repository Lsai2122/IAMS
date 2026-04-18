import 'package:flutter/material.dart';
import '../../widgets/dashboard_card.dart';
import '../login_screen.dart';
import '../events/events_screen.dart';
import '../events/create_event_screen.dart';
import '../events/participants_screen.dart';
import '../events/engagement_screen.dart';

class EventCoordinatorDashboard extends StatelessWidget {
  const EventCoordinatorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Operations'),
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
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Command Center',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Manage and monitor all campus activities',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DashboardCard(
                  icon: Icons.add_circle_outline_rounded,
                  label: 'Create Event',
                  color: Colors.blue,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateEventScreen())),
                ),
                DashboardCard(
                  icon: Icons.event_note_outlined,
                  label: 'All Events',
                  color: Colors.purple,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventsScreen())),
                ),
                DashboardCard(
                  icon: Icons.people_outline_rounded,
                  label: 'Participants',
                  color: Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ParticipantsScreen())),
                ),
                DashboardCard(
                  icon: Icons.analytics_outlined,
                  label: 'Engagement',
                  color: Colors.orange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EngagementScreen())),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
