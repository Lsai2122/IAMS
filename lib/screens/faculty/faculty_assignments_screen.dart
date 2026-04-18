import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';
import 'create_assignment_screen.dart';

class FacultyAssignmentsScreen extends StatelessWidget {
  const FacultyAssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assignments'),
      ),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final assignments = academicController.assignments;

          if (assignments.isEmpty) {
            return EmptyStateView(
              icon: Icons.assignment_late_outlined,
              title: 'No Assignments',
              subtitle: 'Create your first assignment to share with students.',
              buttonText: 'Create Now',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assignments.length,
            itemBuilder: (context, index) {
              final asm = assignments[index];
              final deadline = DateTime.parse(asm['deadline']);
              final isOverdue = deadline.isBefore(DateTime.now());

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(asm['courseCode'], style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                          Text(
                            isOverdue ? 'Closed' : 'Active',
                            style: TextStyle(color: isOverdue ? Colors.red : Colors.green, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(asm['title'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(asm['description'], style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      const Divider(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Deadline', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              Text(
                                "${deadline.day}/${deadline.month}/${deadline.year} at ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () async {
                              final newDate = await showDatePicker(
                                context: context,
                                initialDate: deadline,
                                firstDate: DateTime.now(),
                                lastDate: academicController.semesterEnd,
                              );
                              if (newDate != null) {
                                academicController.extendAssignmentDeadline(asm['id'], newDate);
                              }
                            },
                            child: const Text('Extend'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateAssignmentScreen()),
        ),
        child: const Icon(Icons.add_task_rounded),
      ),
    );
  }
}
