import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class AnonymousQueryScreen extends StatefulWidget {
  const AnonymousQueryScreen({super.key});

  @override
  State<AnonymousQueryScreen> createState() => _AnonymousQueryScreenState();
}

class _AnonymousQueryScreenState extends State<AnonymousQueryScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedCategory = 'Academic';
  String? _ticketId;
  bool _isTracking = false;
  final _ticketController = TextEditingController();

  final List<String> _categories = ['Academic', 'Infrastructure', 'Fee-Related', 'Faculty Conduct', 'Harassment', 'Others'];

  String _generateTicketId() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = List.generate(8, (i) => chars[(DateTime.now().millisecondsSinceEpoch + i * 37) % chars.length]);
    return rand.join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anonymous Grievance'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_ticketId != null) ...[
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.teal.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.teal.shade100),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 56),
                    const SizedBox(height: 16),
                    const Text(
                      'Query Submitted Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    const Text('Please save your Ticket ID to track progress:'),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _ticketId!,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          letterSpacing: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],

            const Text('New Submission', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Text('Your identity remains strictly anonymous.', style: TextStyle(color: AppTheme.textLight)),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setState(() => _selectedCategory = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _subjectController,
              decoration: const InputDecoration(
                labelText: 'Subject',
                prefixIcon: Icon(Icons.subject_rounded),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _messageController,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Describe your grievance',
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                if (_subjectController.text.isEmpty || _messageController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
                  return;
                }
                setState(() => _ticketId = _generateTicketId());
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
              child: const Text('Submit Anonymously'),
            ),

            const SizedBox(height: 48),
            const Divider(),
            const SizedBox(height: 32),

            const Text('Track Existing Query', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ticketController,
                    decoration: const InputDecoration(
                      labelText: 'Enter Ticket ID',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => setState(() => _isTracking = true),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Track'),
                  ),
                ),
              ],
            ),
            if (_isTracking) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.orange.shade50, shape: BoxShape.circle),
                        child: const Icon(Icons.pending_actions_rounded, color: Colors.orange),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Status: In Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('Our team is reviewing your query.', style: TextStyle(color: AppTheme.textLight, fontSize: 13)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
