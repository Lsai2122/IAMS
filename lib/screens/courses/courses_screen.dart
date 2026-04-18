import 'package:flutter/material.dart';
import '../../controllers/academic_controller.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state_view.dart';
import 'course_detail_screen.dart';

class CoursesScreen extends StatefulWidget {
  const CoursesScreen({super.key});

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  void _addCourse() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final codeController = TextEditingController();
        final facultyController = TextEditingController();
        final creditsController = TextEditingController();
        Color selectedColor = AppTheme.primaryBlue;

        return AlertDialog(
          title: const Text('Register New Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Course Title')),
                const SizedBox(height: 12),
                TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Course Code (e.g. CS301)')),
                const SizedBox(height: 12),
                TextField(controller: facultyController, decoration: const InputDecoration(labelText: 'Faculty Name')),
                const SizedBox(height: 12),
                TextField(controller: creditsController, decoration: const InputDecoration(labelText: 'Credits'), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                const Text('Select Theme Color:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [Colors.blue, Colors.orange, Colors.purple, Colors.teal, Colors.red].map((color) {
                    return GestureDetector(
                      onTap: () => selectedColor = color,
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty && codeController.text.isNotEmpty) {
                  academicController.registerCourse(
                    code: codeController.text,
                    title: titleController.text,
                    faculty: facultyController.text,
                    credits: int.tryParse(creditsController.text) ?? 3,
                    color: selectedColor,
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text('Register'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(icon: const Icon(Icons.add_task_rounded), onPressed: _addCourse),
        ],
      ),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final courses = academicController.courses;
          
          if (courses.isEmpty) {
            return EmptyStateView(
              icon: Icons.auto_stories_rounded,
              title: 'No Enrolled Courses',
              subtitle: 'Start your academic journey by adding your first course!',
              buttonText: 'Add Course',
              onAction: _addCourse,
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
                  leading: CircleAvatar(
                    backgroundColor: course['color'].withOpacity(0.1),
                    child: Text(course['code']![0], style: TextStyle(color: course['color'], fontWeight: FontWeight.bold)),
                  ),
                  title: Text(course['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${course['code']} • ${course['credits']} Credits • ${course['faculty']}'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCourse,
        child: const Icon(Icons.add),
      ),
    );
  }
}
