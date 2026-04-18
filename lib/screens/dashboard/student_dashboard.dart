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

        return RefreshIndicator(
          onRefresh: () => academicController.fetchOrganizationalData(context),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with Sync Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Welcome back,', style: TextStyle(color: AppTheme.textLight, fontSize: 16)),
                        const Text('Rahul Sharma', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
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
                              width: 10,
                              height: 10,
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

                // To-Do List (Personal Data)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('My To-Do List', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.lock_outline, size: 16, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 8),
                if (academicController.todoList.isEmpty)
                  EmptyStateView(
                    icon: Icons.checklist_rounded,
                    title: 'No Tasks',
                    subtitle: 'Your personal tasks are stored only on this device.',
                    buttonText: 'Add Task',
                    onAction: () {}, 
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
