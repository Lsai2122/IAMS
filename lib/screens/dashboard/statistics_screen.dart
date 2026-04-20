import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../attendance/attendance_history_screen.dart';
import '../courses/course_detail_screen.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Performance Statistics')),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final attendanceData = academicController.getAttendanceStats();
          final courses = academicController.courses;
          final cgpa = academicController.gpa;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Summary Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSummaryStat('CGPA', cgpa.toStringAsFixed(2)),
                      _buildSummaryStat('Attendance', _calculateOverallAttendance(attendanceData)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Attendance Section
                const Text('Attendance Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...attendanceData.map((data) => _buildAttendanceCard(context, data)).toList(),

                const SizedBox(height: 32),

                // Grades Section
                const Text('Course Grades', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...courses.map((c) => _buildGradeCard(context, c)).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  String _calculateOverallAttendance(List<Map<String, dynamic>> data) {
    if (data.isEmpty) return '0%';
    int attended = 0;
    int total = 0;
    for (var d in data) {
      attended += (d['attended'] as int);
      total += (d['total'] as int);
    }
    return total == 0 ? '0%' : '${((attended / total) * 100).toStringAsFixed(0)}%';
  }

  Widget _buildSummaryStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }

  Widget _buildAttendanceCard(BuildContext context, Map<String, dynamic> data) {
    final double ratio = data['total'] == 0 ? 0 : data['attended'] / data['total'];
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen(courseCode: data['code'], courseTitle: data['class']))),
        title: Text(data['class'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          children: [
            const SizedBox(height: 8),
            LinearProgressIndicator(value: ratio, backgroundColor: Colors.grey.shade100, valueColor: AlwaysStoppedAnimation<Color>(data['color'])),
          ],
        ),
        trailing: Text('${(ratio * 100).toStringAsFixed(0)}%', style: TextStyle(fontWeight: FontWeight.bold, color: data['color'])),
      ),
    );
  }

  Widget _buildGradeCard(BuildContext context, Map<String, dynamic> course) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CourseDetailScreen(course: course))),
        title: Text(course['title'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Credits: ${course['credits']}'),
        trailing: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
          child: Text(course['grade'] ?? 'N/A', style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}
