import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';

class AttendanceHistoryScreen extends StatelessWidget {
  final String courseCode;
  final String courseTitle;

  const AttendanceHistoryScreen({
    super.key,
    required this.courseCode,
    required this.courseTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(courseTitle, style: const TextStyle(fontSize: 18)),
            Text('Attendance History', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final history = academicController.getAttendanceHistory(courseCode);

          if (history.isEmpty) {
            return const Center(child: Text('No classes scheduled for this course yet.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (context, index) {
              final record = history[index];
              final bool? isPresent = record['status'];
              final String slotId = record['id'];
              final String dateKey = record['date'];
              
              Color statusColor = Colors.grey;
              String statusText = 'Not Marked';
              IconData statusIcon = Icons.help_outline;

              if (isPresent == true) {
                statusColor = Colors.green;
                statusText = 'Present';
                statusIcon = Icons.check_circle_rounded;
              } else if (isPresent == false) {
                statusColor = Colors.red;
                statusText = 'Absent';
                statusIcon = Icons.cancel_rounded;
              }

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              record['date'],
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text('${record['time']} • ${record['location']}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                      // New Interactive Marking Buttons
                      Row(
                        children: [
                          _SmallAttendanceButton(
                            icon: Icons.check_rounded,
                            color: Colors.green,
                            isSelected: isPresent == true,
                            onTap: () => academicController.markAttendance(dateKey, slotId, true),
                          ),
                          const SizedBox(width: 8),
                          _SmallAttendanceButton(
                            icon: Icons.close_rounded,
                            color: Colors.red,
                            isSelected: isPresent == false,
                            onTap: () => academicController.markAttendance(dateKey, slotId, false),
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
    );
  }
}

class _SmallAttendanceButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _SmallAttendanceButton({required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 16, color: isSelected ? Colors.white : color),
      ),
    );
  }
}
