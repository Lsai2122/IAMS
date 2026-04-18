import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';

class CreateAssignmentScreen extends StatefulWidget {
  const CreateAssignmentScreen({super.key});

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String? _selectedCourseCode;
  DateTime _selectedDeadline = DateTime.now().add(const Duration(days: 7));

  @override
  Widget build(BuildContext context) {
    final courses = academicController.courses.where((c) => !(c['isPersonal'] ?? false)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Assignment Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            DropdownButtonFormField<String>(
              value: _selectedCourseCode,
              decoration: const InputDecoration(labelText: 'Select Course'),
              items: courses.map((c) => DropdownMenuItem(
                value: c['code'] as String,
                child: Text(c['title'] as String),
              )).toList(),
              onChanged: (v) => setState(() => _selectedCourseCode = v),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title', hintText: 'e.g. Lab Report 1'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Description', hintText: 'Assignment instructions...'),
            ),
            const SizedBox(height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Submission Deadline', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("${_selectedDeadline.day}/${_selectedDeadline.month}/${_selectedDeadline.year}"),
              trailing: ElevatedButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDeadline,
                    firstDate: DateTime.now(),
                    lastDate: academicController.semesterEnd,
                  );
                  if (picked != null) setState(() => _selectedDeadline = picked);
                },
                child: const Text('Select Date'),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                if (_titleController.text.isNotEmpty && _selectedCourseCode != null) {
                  academicController.createAssignment(
                    title: _titleController.text,
                    description: _descController.text,
                    courseCode: _selectedCourseCode!,
                    deadline: _selectedDeadline,
                  );
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assignment Published!'), behavior: SnackBarBehavior.floating),
                  );
                }
              },
              child: const Text('Publish Assignment'),
            ),
          ],
        ),
      ),
    );
  }
}
