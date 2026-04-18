import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../attendance/attendance_history_screen.dart';

class CourseDetailScreen extends StatelessWidget {
  final Map<String, dynamic> course;

  const CourseDetailScreen({super.key, required this.course});

  void _editMarks(BuildContext context, String type, int currentVal) {
    final controller = TextEditingController(text: currentVal.toString());
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit $type Marks'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Score', hintText: 'Enter marks obtained'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null) {
                academicController.updateMarks(course['code'], type, val);
                Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _editGrade(BuildContext context, String currentGrade) {
    String selectedGrade = currentGrade;
    final grades = ['O', 'A+', 'A', 'B+', 'B', 'C', 'P', 'F', 'N/A'];
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Grade'),
        content: DropdownButtonFormField<String>(
          value: grades.contains(selectedGrade) ? selectedGrade : 'N/A',
          items: grades.map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
          onChanged: (v) => selectedGrade = v!,
          decoration: const InputDecoration(labelText: 'Select Grade'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              academicController.updateGrade(course['code'], selectedGrade);
              Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: academicController,
      builder: (context, _) {
        final liveCourse = academicController.courses.firstWhere((c) => c['code'] == course['code']);
        
        final stats = academicController.getAttendanceStats();
        final courseStats = stats.firstWhere(
          (s) => s['code'] == liveCourse['code'], 
          orElse: () => {'attended': 0, 'total': 0}
        );
        final double attendanceRatio = courseStats['total'] == 0 ? 0 : courseStats['attended'] / courseStats['total'];

        // Fix: Int not subtype of Color
        final Color courseColor = liveCourse['color'] is int 
            ? Color(liveCourse['color']) 
            : (liveCourse['color'] as Color? ?? Colors.blue);

        return Scaffold(
          appBar: AppBar(
            title: Text(liveCourse['title'] ?? 'Course Details'),
            backgroundColor: Colors.transparent,
            actions: [
              IconButton(
                icon: const Icon(Icons.grade_rounded),
                onPressed: () => _editGrade(context, liveCourse['grade'] ?? 'N/A'),
                tooltip: 'Update Grade',
              ),
              const SizedBox(width: 8),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [courseColor, courseColor.withOpacity(0.7)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(liveCourse['code'] ?? '', style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                            child: Text('Grade: ${liveCourse['grade'] ?? 'N/A'}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(liveCourse['title'] ?? '', style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Text('Faculty: ${liveCourse['faculty'] ?? 'TBD'}', style: const TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Attendance Section
                const Text('Attendance Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AttendanceHistoryScreen(
                        courseCode: liveCourse['code'],
                        courseTitle: liveCourse['title'],
                      ),
                    ),
                  ),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${(attendanceRatio * 100).toStringAsFixed(1)}%', 
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: courseColor)),
                            Row(
                              children: [
                                Text('${courseStats['attended']} / ${courseStats['total']} Classes', style: const TextStyle(color: Colors.grey)),
                                const SizedBox(width: 8),
                                const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: attendanceRatio,
                            minHeight: 10,
                            backgroundColor: courseColor.withOpacity(0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(courseColor),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Marks Section
                const Text('Academic Marks (Tap to Edit)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildMarkCard(context, 'Internal', liveCourse['marks']?['Internal'] ?? 0, 25, Colors.blue),
                    const SizedBox(width: 12),
                    _buildMarkCard(context, 'Mid-term', liveCourse['marks']?['Mid-term'] ?? 0, 50, Colors.orange),
                    const SizedBox(width: 12),
                    _buildMarkCard(context, 'Target', liveCourse['marks']?['Target'] ?? 75, 100, Colors.green, isPercent: true),
                  ],
                ),
                const SizedBox(height: 32),

                // Notes Section
                const Text('Class Notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (liveCourse['notes'] != null)
                  ...(liveCourse['notes'] as List).map((note) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.description_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                        Expanded(child: Text(note.toString(), style: const TextStyle(fontWeight: FontWeight.w500))),
                        const Icon(Icons.chevron_right, color: Colors.grey, size: 18),
                      ],
                    ),
                  )).toList(),
                if (liveCourse['notes'] == null || (liveCourse['notes'] as List).isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Text('No notes available yet', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildMarkCard(BuildContext context, String label, int value, int total, Color color, {bool isPercent = false}) {
    return Expanded(
      child: InkWell(
        onTap: () => _editMarks(context, label, value),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withOpacity(0.05),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.1)),
          ),
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(isPercent ? '$value%' : '$value/$total', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              const Icon(Icons.edit_outlined, size: 12, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
