import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_view.dart';

class EventInboxScreen extends StatelessWidget {
  const EventInboxScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Logic for messages will go here
    final List<Map<String, String>> messages = []; 

    return Scaffold(
      appBar: AppBar(title: const Text('Coordinator Inbox')),
      body: messages.isEmpty
          ? const EmptyStateView(
              icon: Icons.mail_outline_rounded,
              title: 'No New Messages',
              subtitle: 'Inquiries from participants and system alerts will appear here.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(msg['sender'] ?? ''),
                    subtitle: Text(msg['preview'] ?? ''),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}
