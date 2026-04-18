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
  void _addPersonalCourse() {
    showDialog(
      context: context,
      builder: (context) {
        final titleController = TextEditingController();
        final codeController = TextEditingController();
        final creditsController = TextEditingController();
        Color selectedColor = Colors.blue;

        return AlertDialog(
          title: const Text('Add Personal Course'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Course Title')),
                const SizedBox(height: 12),
                TextField(controller: codeController, decoration: const InputDecoration(labelText: 'Short Code')),
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
                        width: 30, height: 30,
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
                  academicController.registerPersonalCourse(
                    code: codeController.text,
                    title: titleController.text,
                    credits: int.tryParse(creditsController.text) ?? 0,
                    color: selectedColor,
                  );
                  Navigator.pop(context);
                }
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync_rounded),
            onPressed: () => academicController.fetchOrganizationalData(context),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final allCourses = academicController.courses;
          
          if (allCourses.isEmpty && !academicController.isLoading) {
            return EmptyStateView(
              icon: Icons.auto_stories_rounded,
              title: 'No Courses Found',
              subtitle: 'Add a personal course or sync with college server.',
              buttonText: 'Add Personal Course',
              onAction: _addPersonalCourse,
            );
          }

          if (academicController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: allCourses.length,
            itemBuilder: (context, index) {
              final course = allCourses[index];
              final bool isPersonal = course['isPersonal'] ?? false;
              
              final Color courseColor = course['color'] is int 
                ? Color(course['color']) 
                : (course['color'] as Color? ?? Colors.blue);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
                  leading: CircleAvatar(
                    backgroundColor: courseColor.withOpacity(0.1),
                    child: Text(
                      (course['code'] as String? ?? '?')[0], 
                      style: TextStyle(color: courseColor, fontWeight: FontWeight.bold)
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(course['title'] ?? 'Unknown Course', style: const TextStyle(fontWeight: FontWeight.bold)),
                      if (isPersonal) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                      ],
                    ],
                  ),
                  subtitle: Text('${course['code'] ?? '???'} • ${course['credits'] ?? 0} Credits'),
                  trailing: isPersonal ? const Icon(Icons.lock_outline, size: 16, color: Colors.grey) : const Icon(Icons.business_outlined, size: 16, color: AppTheme.primaryBlue),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addPersonalCourse,
        tooltip: 'Add Personal Course',
        child: const Icon(Icons.add),
      ),
    );
  }
}
