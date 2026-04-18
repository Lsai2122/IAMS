import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MaterialsScreen extends StatelessWidget {
  const MaterialsScreen({super.key});

  final List<Map<String, dynamic>> materials = const [
    {
      'name': 'SQL Queries Guide.pdf',
      'course': 'Database Systems',
      'size': '1.5 MB',
      'time': '2023-10-15 14:00:00'
    },
    {
      'name': 'Lecture 1 - Intro.pdf',
      'course': 'Database Systems',
      'size': '2.3 MB',
      'time': '2023-10-01 10:30:00'
    },
    {
      'name': 'Calculus Notes.docx',
      'course': 'Engineering Math',
      'size': '1.1 MB',
      'time': '2023-10-12 09:00:00'
    },
    {
      'name': 'Unit 3 Slides.pptx',
      'course': 'Software Eng.',
      'size': '5.7 MB',
      'time': '2023-10-10 11:30:00'
    },
    {
      'name': 'ER Diagram Practice.png',
      'course': 'Database Systems',
      'size': '0.8 MB',
      'time': '2023-10-18 16:45:00'
    },
  ];

  Map<String, List<Map<String, dynamic>>> get groupedMaterials {
    // 1. Sort by time (most recent first)
    List<Map<String, dynamic>> sorted = List.from(materials);
    sorted.sort((a, b) => b['time'].compareTo(a['time']));

    // 2. Group by course
    Map<String, List<Map<String, dynamic>>> groups = {};
    for (var item in sorted) {
      String course = item['course'];
      if (!groups.containsKey(course)) {
        groups[course] = [];
      }
      groups[course]!.add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final grouped = groupedMaterials;
    final courses = grouped.keys.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Library')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: courses.length,
        itemBuilder: (context, index) {
          final courseName = courses[index];
          final courseFiles = grouped[courseName]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Text(
                  courseName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryBlue,
                  ),
                ),
              ),
              ...courseFiles.map((file) => _MaterialTile(
                    name: file['name'],
                    course: file['course'],
                    size: file['size'],
                    time: file['time'],
                  )),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('File picker would open here'),
              behavior: SnackBarBehavior.floating),
        ),
        icon: const Icon(Icons.upload_file_rounded),
        label: const Text('Upload'),
      ),
    );
  }
}

class _MaterialTile extends StatelessWidget {
  final String name, course, size, time;
  const _MaterialTile(
      {required this.name,
      required this.course,
      required this.size,
      required this.time});

  String _formatDate(String dateStr) {
    try {
      DateTime dt = DateTime.parse(dateStr);
      return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppTheme.primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.insert_drive_file_outlined,
              color: AppTheme.primaryBlue),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('$size • ${_formatDate(time)}'),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.download_for_offline_outlined,
              color: AppTheme.primaryBlue),
          onPressed: () {},
        ),
      ),
    );
  }
}
