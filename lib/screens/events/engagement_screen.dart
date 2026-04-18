import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';

class EngagementScreen extends StatelessWidget {
  const EngagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Engagement Analytics')),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          final events = academicController.allEvents;

          if (events.isEmpty) {
            return const EmptyStateView(
              icon: Icons.analytics_outlined,
              title: 'No Data to Analyze',
              subtitle: 'Create your first event to start tracking student engagement.',
            );
          }

          int totalRegistrations = 0;
          for (var e in events) {
            totalRegistrations += (e['registrations'] as int? ?? 0);
          }

          // Calculate average interest based on capacity
          double avgInterest = 0;
          if (events.isNotEmpty) {
            double totalInterest = 0;
            for (var e in events) {
              int cap = e['capacity'] as int? ?? 1;
              int reg = e['registrations'] as int? ?? 0;
              totalInterest += (reg / cap);
            }
            avgInterest = (totalInterest / events.length) * 100;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Operational Metrics', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat('Active Events', events.length.toString()),
                      _buildStat('Total Reach', totalRegistrations.toString()),
                      _buildStat('Interest Rate', '${avgInterest.toStringAsFixed(1)}%'),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                const Text('Registration Capacity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...events.map((e) {
                  final int regCount = e['registrations'] as int? ?? 0;
                  final int capacity = e['capacity'] as int? ?? 1;
                  final double progress = regCount / capacity;
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(e['title'] ?? 'Unnamed Event', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('$regCount / $capacity', style: TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade100,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}% Filled',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ],
    );
  }
}
