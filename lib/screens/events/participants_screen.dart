import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event Participants')),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          // In a real app, this would fetch from a 'participants' table in Postgres.
          // For now, we simulate based on registered events.
          final events = academicController.allEvents;
          
          if (events.isEmpty) {
            return const EmptyStateView(
              icon: Icons.people_outline_rounded,
              title: 'No Participants Yet',
              subtitle: 'Wait for students to register for your events.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final e = events[index];
              // Simulated participant count
              final count = (e['id'] * 15) % 40; 

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                    child: Icon(Icons.event, color: AppTheme.primaryBlue, size: 20),
                  ),
                  title: Text(e['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$count Students Registered'),
                  children: [
                    // Simulated list of names
                    ...List.generate(3, (i) => ListTile(
                      leading: const CircleAvatar(radius: 12, backgroundImage: NetworkImage('https://i.pravatar.cc/100')),
                      title: Text('Student Participant ${i + 1}'),
                      subtitle: const Text('ID: 2021BCS001'),
                      trailing: IconButton(
                        icon: const Icon(Icons.mail_outline, size: 18),
                        onPressed: () {},
                      ),
                    )),
                    if (count > 3)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('... and ${count - 3} more', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
