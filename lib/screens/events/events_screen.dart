import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Events'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryBlue,
          unselectedLabelColor: AppTheme.textLight,
          indicatorColor: AppTheme.primaryBlue,
          tabs: const [
            Tab(text: 'All Events'),
            Tab(text: 'My Registrations'),
          ],
        ),
      ),
      body: ListenableBuilder(
        listenable: academicController,
        builder: (context, _) {
          return TabBarView(
            controller: _tabController,
            children: [
              _buildEventList(academicController.allEvents, isAllTab: true),
              _buildEventList(academicController.registeredEvents, isAllTab: false),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEventList(List<Map<String, dynamic>> events, {required bool isAllTab}) {
    if (events.isEmpty) {
      return EmptyStateView(
        icon: Icons.event_busy_rounded,
        title: isAllTab ? 'No Events Available' : 'No Registered Events',
        subtitle: isAllTab 
          ? 'Check back later for upcoming campus activities!' 
          : 'You haven\'t registered for any events yet. Browse "All Events" to get started.',
        buttonText: !isAllTab ? 'Browse Events' : null,
        onAction: !isAllTab ? () => _tabController.animateTo(0) : null,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final e = events[index];
        final bool isRegistered = e['isRegistered'] ?? false;

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
                      child: Text(e['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryBlue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        e['category'] ?? 'General',
                        style: const TextStyle(color: AppTheme.primaryBlue, fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: AppTheme.textLight),
                    const SizedBox(width: 8),
                    Text(e['date'] ?? 'TBD', style: const TextStyle(color: AppTheme.textLight)),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      academicController.toggleEventRegistration(e['id']);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(isRegistered ? 'Unregistered from ${e['title']}' : 'Registered for ${e['title']}!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRegistered ? Colors.grey.shade200 : AppTheme.primaryBlue,
                      foregroundColor: isRegistered ? AppTheme.textDark : Colors.white,
                    ),
                    child: Text(isRegistered ? 'Unregister' : 'Register Now'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
