import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class ManageUsersScreen extends StatelessWidget {
  const ManageUsersScreen({super.key});

  final List<Map<String, String>> users = const [
    {'name': 'Rahul Sharma', 'email': 'rahul@uni.ac.in', 'role': 'Student', 'status': 'Active'},
    {'name': 'Dr. Priya Patel', 'email': 'priya@uni.ac.in', 'role': 'Faculty', 'status': 'Active'},
    {'name': 'Sneha Reddy', 'email': 'sneha@uni.ac.in', 'role': 'Student', 'status': 'Active'},
    {'name': 'Coordinator Jay', 'email': 'jay@uni.ac.in', 'role': 'Event Coordinator', 'status': 'Active'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User Management')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: users.length,
        itemBuilder: (context, index) {
          final u = users[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(
                backgroundColor: AppTheme.primaryBlue.withOpacity(0.1),
                child: Text(
                  u['name']![0],
                  style: const TextStyle(color: AppTheme.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${u['email']} • ${u['role']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  u['status']!,
                  style: const TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.person_add_alt_1_rounded),
      ),
    );
  }
}
