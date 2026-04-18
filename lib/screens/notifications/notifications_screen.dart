import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  final List<Map<String, String>> notifications = const [
    {'title': 'Grade Posted', 'message': 'Your grade for CS101 has been posted.', 'time': '2 hrs ago'},
    {'title': 'Event Update', 'message': 'Tech Fest venue changed to Main Hall.', 'time': '5 hrs ago'},
    {'title': 'Announcement', 'message': 'Assignment 2 deadline extended to Friday.', 'time': '1 day ago'},
    {'title': 'Query Update', 'message': 'Your grievance TK3X9A1B is In Progress.', 'time': '2 days ago'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final n = notifications[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppTheme.primaryBlue),
              ),
              title: Text(n['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(n['message']!),
              ),
              trailing: Text(
                n['time']!,
                style: const TextStyle(color: AppTheme.textLight, fontSize: 12),
              ),
            ),
          );
        },
      ),
    );
  }
}
