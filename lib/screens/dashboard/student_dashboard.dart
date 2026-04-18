import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final List<String> _classes = ['Database Systems', 'Engineering Math', 'Software Eng.', 'Programming Lab', 'General'];

  void _addTodo() {
    showDialog(
      context: context,
      builder: (context) {
        String title = '';
        String selectedClass = 'General';
        return AlertDialog(
          title: const Text('Add Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                onChanged: (v) => title = v,
                decoration: const InputDecoration(labelText: 'Task Title'),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedClass,
                decoration: const InputDecoration(labelText: 'Related Class'),
                items: _classes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => selectedClass = v!,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (title.isNotEmpty) {
                  academicController.addTodo(title, selectedClass);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: academicController,
      builder: (context, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome back,',
                        style: TextStyle(color: AppTheme.textLight, fontSize: 16),
                      ),
                      const Text(
                        'Rahul Sharma',
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 28,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=rahul'),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Deadlines Section
              const Text(
                'Upcoming Deadlines',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const _DeadlineCard(
                title: 'Database Assignment',
                course: 'CS301 • SQL Queries',
                time: 'Due in 4 hours',
                color: Colors.orange,
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: 32),

              // To-Do List Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'My To-Do List',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    onPressed: _addTodo,
                    icon: const Icon(Icons.add_circle_outline, color: AppTheme.primaryBlue),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Corrected: Handled dynamic list safely
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: academicController.todoList.length,
                itemBuilder: (context, index) {
                  final item = academicController.todoList[index];
                  // Use null-aware operator or cast properly
                  final String title = item['title'] ?? 'Untitled Task';
                  final bool isDone = item['isDone'] ?? false;
                  final String className = item['courseCode'] ?? item['class'] ?? 'General';
                  
                  return _TodoItem(
                    title: title,
                    isDone: isDone,
                    className: className,
                    onToggle: () => academicController.toggleTodo(index),
                  );
                },
              ),
              
              const SizedBox(height: 32),
              
              // Motivational Card
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.white, size: 32),
                    SizedBox(height: 16),
                    Text(
                      'Daily Tip',
                      style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '"Consistency is the key to academic success. Check your stats in the main dashboard!"',
                      style: TextStyle(color: Colors.white, fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
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
            Icon(
              isDone ? Icons.check_circle : Icons.circle_outlined,
              color: isDone ? Colors.green : Colors.grey,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      decoration: isDone ? TextDecoration.lineThrough : null,
                      color: isDone ? Colors.grey : null,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    className,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineCard extends StatelessWidget {
  final String title, course, time;
  final Color color;
  final IconData icon;

  const _DeadlineCard({required this.title, required this.course, required this.time, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                Text(course, style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
