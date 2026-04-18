import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_view.dart';

class EventNoticesScreen extends StatelessWidget {
  const EventNoticesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic for notices will go here (AcademicController)
    final List<Map<String, String>> notices = []; 

    return Scaffold(
      appBar: AppBar(title: const Text('Campus Notices')),
      body: notices.isEmpty
          ? const EmptyStateView(
              icon: Icons.campaign_outlined,
              title: 'No Active Notices',
              subtitle: 'Campus announcements and official alerts will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notices.length,
              itemBuilder: (context, index) {
                final notice = notices[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Colors.orange,
                      child: Icon(Icons.priority_high, color: Colors.white),
                    ),
                    title: Text(notice['title'] ?? ''),
                    subtitle: Text(notice['content'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add_comment_rounded),
      ),
    );
  }
}
