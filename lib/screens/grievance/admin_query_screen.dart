import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AdminQueryScreen extends StatelessWidget {
  const AdminQueryScreen({super.key});

  final List<Map<String, String>> queries = const [
    {'ticket': 'AB12CD34', 'category': 'Academic', 'subject': 'Grade discrepancy in CS101', 'status': 'Open'},
    {'ticket': 'XY98ZT01', 'category': 'Infrastructure', 'subject': 'AC not working in Lab 3', 'status': 'In Progress'},
    {'ticket': 'MN45OP67', 'category': 'Fee-Related', 'subject': 'Scholarship not applied', 'status': 'Resolved'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Grievance Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: queries.length,
        itemBuilder: (context, index) {
          final q = queries[index];
          final statusColor = q['status'] == 'Open' 
              ? Colors.red 
              : q['status'] == 'In Progress' 
                  ? Colors.orange 
                  : Colors.teal;
                  
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
                      Text(
                        'Ticket: ${q['ticket']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          q['status']!,
                          style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    q['subject']!,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Category: ${q['category']}',
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 14),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppTheme.primaryBlue),
                            foregroundColor: AppTheme.primaryBlue,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Respond'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            foregroundColor: AppTheme.textDark,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Escalate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
