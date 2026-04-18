import 'package:flutter/material.dart';
import '../../controllers/academic_controller.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Attendance')),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final attendanceData = academicController.getAttendanceStats();
          
          if (attendanceData.isEmpty) {
            return const Center(child: Text('No attendance records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: attendanceData.length,
            itemBuilder: (context, index) {
              final a = attendanceData[index];
              final total = a['total'] as int;
              final attended = a['attended'] as int;
              final ratio = total == 0 ? 0.0 : attended / total;
              final percent = (ratio * 100).toStringAsFixed(1);
              final Color color = a['color'] as Color;

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              a['class'],
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '$percent%',
                              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 8,
                          backgroundColor: Colors.grey.shade100,
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '$attended attended of $total total classes',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
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
