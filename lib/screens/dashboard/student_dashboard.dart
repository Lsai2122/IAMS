import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  void _showAddTaskDialog() {
    final courses = academicController.courses;
    final titleController = TextEditingController();
    String? selectedCourseCode = courses.isNotEmpty ? courses.first['code'] : null;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            title: const Text('Add New Task'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    hintText: 'e.g. Finish Assignment',
                  ),
                ),
                const SizedBox(height: 16),
                if (courses.isNotEmpty)
                  DropdownButtonFormField<String>(
                    value: selectedCourseCode,
                    decoration: const InputDecoration(labelText: 'Related Course'),
                    items: courses.map((c) => DropdownMenuItem(
                      value: c['code'] as String,
                      child: Text(c['title'] as String),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedCourseCode = v),
                  )
                else
                  const Text('No courses registered. Add a course first to link tasks.', 
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.isNotEmpty) {
                    academicController.addTodo(
                      titleController.text, 
                      selectedCourseCode ?? 'General'
                    );
                    Navigator.pop(context);
                  }
                },
                child: const Text('Add Task'),
              ),
            ],
          );
        }
      ),
    );
  }

  void _showAssignmentInfo(Map<String, dynamic> assignment) {
    final deadline = DateTime.parse(assignment['deadline']);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(assignment['title'] ?? 'Assignment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow(Icons.book_outlined, 'Course', assignment['courseCode'] ?? 'N/A'),
            const SizedBox(height: 12),
            _infoRow(Icons.event_available_outlined, 'Deadline', 
              "${deadline.day}/${deadline.month}/${deadline.year} at ${deadline.hour}:${deadline.minute.toString().padLeft(2, '0')}"),
            const SizedBox(height: 16),
            const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Text(assignment['description'] ?? 'No additional instructions provided.', 
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              // Add submission logic or link handling here
              Navigator.pop(context);
            },
            child: const Text('Go to Course'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primaryBlue),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: academicController,
      builder: (context, _) {
        if (academicController.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Syncing with College Server...', style: TextStyle(color: Colors.grey)),
              ],
            ),
          );
        }

        final now = DateTime.now();
        final List<Map<String, dynamic>> upcomingAssignments = academicController.assignments.where((a) {
          final deadline = DateTime.tryParse(a['deadline'] ?? '');
          return deadline != null && deadline.isAfter(now);
        }).toList();

        upcomingAssignments.sort((a, b) {
          final da = DateTime.parse(a['deadline']);
          final db = DateTime.parse(b['deadline']);
          return da.compareTo(db);
        });

        final topThree = upcomingAssignments.take(3).toList();

        return RefreshIndicator(
          onRefresh: () => academicController.fetchOrganizationalData(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                        Text(academicController.currentStudentName ?? 'Student', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Stack(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.sync_rounded, color: AppTheme.primaryBlue),
                          onPressed: () => academicController.fetchOrganizationalData(context),
                        ),
                        if (academicController.syncFailed)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 10, height: 10,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                if (academicController.syncFailed)
                  Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red.shade100)),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Sync failed. Displaying last known offline data.',
                            style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                        ),
                        TextButton(
                          onPressed: () => academicController.fetchOrganizationalData(context),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),

                // Upcoming Deadlines Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Upcoming Deadlines', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    if (upcomingAssignments.length > 3)
                      TextButton(
                        onPressed: () {},
                        child: const Text('Show All'),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (topThree.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('No upcoming deadlines! 🎉', style: TextStyle(color: Colors.grey))),
                  )
                else
                  ...topThree.map((a) {
                    final deadline = DateTime.parse(a['deadline']);
                    final diff = deadline.difference(now);
                    String timeLabel;
                    if (diff.inDays > 0) {
                      timeLabel = 'Due in ${diff.inDays} days';
                    } else if (diff.inHours > 0) {
                      timeLabel = 'Due in ${diff.inHours} hours';
                    } else {
                      timeLabel = 'Due in ${diff.inMinutes} minutes';
                    }

                    return GestureDetector(
                      onTap: () => _showAssignmentInfo(a),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.grey.withOpacity(0.1)),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.assignment_outlined, color: AppTheme.primaryBlue),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a['title'] ?? 'Assignment', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(a['courseCode'] ?? 'Course', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                ],
                              ),
                            ),
                            Text(timeLabel, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),

                const SizedBox(height: 32),

                // To-Do List (Personal Data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My To-Do List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.primaryBlue, size: 20),
                          onPressed: _showAddTaskDialog,
                        ),
                        const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (academicController.todoList.isEmpty)
                  EmptyStateView(
                    icon: Icons.checklist_rounded,
                    title: 'No Tasks',
                    subtitle: 'Your personal tasks are stored only on this device.',
                    buttonText: 'Add Task',
                    onAction: _showAddTaskDialog, 
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: academicController.todoList.length,
                    itemBuilder: (context, index) {
                      final item = academicController.todoList[index];
                      return _TodoItem(
                        title: item['title'],
                        isDone: item['isDone'],
                        className: item['courseCode'],
                        onToggle: () => academicController.toggleTodo(index),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _TodoItem extends StatelessWidget {
  final String title;
  final bool isDone;
  final String className;
  final VoidCallback onToggle;
  const _TodoItem({required this.title, required this.isDone, required this.className, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(isDone ? Icons.check_circle : Icons.circle_outlined, color: isDone ? Colors.green : Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(decoration: isDone ? TextDecoration.lineThrough : null, fontWeight: FontWeight.w600)),
                  Text(className, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
