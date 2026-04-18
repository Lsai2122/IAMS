import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../controllers/academic_controller.dart';
import '../../widgets/empty_state_view.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  late DateTime _focusedDate;
  final List<String> _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  @override
  void initState() {
    super.initState();
    _focusedDate = DateTime.now();
  }

  String _getDateKey(DateTime date) => "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  String _getDayName(DateTime date) => ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];

  void _showClassDialog({Map<String, dynamic>? editSlot, DateTime? targetDate}) {
    final courses = academicController.courses;
    if (courses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please register a course first!')));
      return;
    }

    final date = targetDate ?? _focusedDate;
    final dayName = _getDayName(date);

    showDialog(
      context: context,
      builder: (context) {
        String selectedCourseCode = editSlot?['courseCode'] ?? courses.first['code'];
        double timeValue = editSlot?['timeValue'] ?? 9.0;
        String location = editSlot?['location'] ?? '';
        
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String formatTime(double value) {
              int hour = value.floor();
              int minute = ((value - hour) * 60).round();
              String period = hour >= 12 ? 'PM' : 'AM';
              int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
              return "${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period";
            }

            return AlertDialog(
              title: Text(editSlot == null ? 'Add Class for $dayName' : 'Edit Class'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    value: selectedCourseCode,
                    decoration: const InputDecoration(labelText: 'Select Course'),
                    items: courses.map((c) => DropdownMenuItem(
                      value: c['code'] as String,
                      child: Text(c['title'] as String),
                    )).toList(),
                    onChanged: (v) => setDialogState(() => selectedCourseCode = v!),
                  ),
                  const SizedBox(height: 24),
                  Text('Time: ${formatTime(timeValue)}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryBlue)),
                  Slider(
                    value: timeValue,
                    min: 7.0, max: 21.0, divisions: 28,
                    label: formatTime(timeValue),
                    onChanged: (v) => setDialogState(() => timeValue = v),
                  ),
                  TextField(
                    controller: TextEditingController(text: location),
                    onChanged: (v) => location = v,
                    decoration: const InputDecoration(labelText: 'Location'),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    if (editSlot == null) {
                      academicController.addClassToTimetable(dayName, selectedCourseCode, formatTime(timeValue), location, timeValue);
                    } else {
                      academicController.editClassInTimetable(dayName, editSlot['id'], selectedCourseCode, formatTime(timeValue), location, timeValue);
                    }
                    Navigator.pop(context);
                  },
                  child: Text(editSlot == null ? 'Add' : 'Save'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Calculate start of current week (Monday)
    DateTime weekStart = _focusedDate.subtract(Duration(days: _focusedDate.weekday - 1));
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Calendar'),
        actions: [
          IconButton(icon: const Icon(Icons.today_rounded), onPressed: () => setState(() => _focusedDate = DateTime.now())),
          IconButton(icon: const Icon(Icons.calendar_month_rounded), onPressed: () async {
            final picked = await showDatePicker(context: context, initialDate: _focusedDate, firstDate: academicController.semesterStart, lastDate: academicController.semesterEnd);
            if (picked != null) setState(() => _focusedDate = picked);
          }),
        ],
      ),
      body: Column(
        children: [
          // Weekly Calendar Strip
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => setState(() => _focusedDate = _focusedDate.subtract(const Duration(days: 7)))),
                    Text(
                      "${_focusedDate.day} ${_days[_focusedDate.weekday - 1]}, ${_focusedDate.year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => setState(() => _focusedDate = _focusedDate.add(const Duration(days: 7)))),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(7, (index) {
                    DateTime date = weekStart.add(Duration(days: index));
                    bool isSelected = date.day == _focusedDate.day && date.month == _focusedDate.month;
                    bool isToday = date.day == DateTime.now().day && date.month == DateTime.now().month;

                    return GestureDetector(
                      onTap: () => setState(() => _focusedDate = date),
                      child: Column(
                        children: [
                          Text(_days[index], style: TextStyle(color: isSelected ? AppTheme.primaryBlue : Colors.grey, fontSize: 12, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                          const SizedBox(height: 8),
                          Container(
                            width: 38, height: 38,
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppTheme.primaryGradient : null,
                              color: !isSelected && isToday ? AppTheme.primaryBlue.withOpacity(0.1) : null,
                              shape: BoxShape.circle,
                              border: isToday && !isSelected ? Border.all(color: AppTheme.primaryBlue, width: 1) : null,
                            ),
                            child: Center(
                              child: Text(
                                "${date.day}",
                                style: TextStyle(color: isSelected ? Colors.white : (isToday ? AppTheme.primaryBlue : null), fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.normal),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListenableBuilder(
              listenable: academicController,
              builder: (context, _) {
                final daySlots = academicController.getTimetableForDate(_focusedDate);
                final dateKey = _getDateKey(_focusedDate);
                
                if (daySlots.isEmpty) {
                  return EmptyStateView(
                    icon: Icons.calendar_today_outlined,
                    title: 'No classes scheduled',
                    subtitle: 'Weekly template is empty for ${_getDayName(_focusedDate)}s.',
                    buttonText: 'Add to Weekly Plan',
                    onAction: () => _showClassDialog(),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: daySlots.length,
                  itemBuilder: (context, index) {
                    final slot = daySlots[index];
                    return Dismissible(
                      key: Key("${slot['id']}_$dateKey"),
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.red.shade400,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: const Icon(Icons.delete_outline, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        color: Colors.blue.shade400,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: const Icon(Icons.edit_outlined, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          academicController.deleteClassFromTimetable(_getDayName(_focusedDate), slot['id']);
                          return true;
                        } else {
                          _showClassDialog(editSlot: slot);
                          return false;
                        }
                      },
                      child: _buildTimeSlot(index, slot, dateKey),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showClassDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildTimeSlot(int index, Map<String, dynamic> slot, String dateKey) {
    final bool? isPresent = slot['attendance'];
    final Color slotColor = slot['color'] as Color;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: slotColor, width: 5)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(slot['time'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(slot['subject'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                Text(slot['location'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Column(
            children: [
              const Text('Mark Attendance', style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _AttendanceButton(
                    icon: Icons.check_rounded,
                    color: Colors.green,
                    isSelected: isPresent == true,
                    onTap: () => academicController.markAttendance(dateKey, slot['id'], true),
                  ),
                  const SizedBox(width: 12),
                  _AttendanceButton(
                    icon: Icons.close_rounded,
                    color: Colors.red,
                    isSelected: isPresent == false,
                    onTap: () => academicController.markAttendance(dateKey, slot['id'], false),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;
  const _AttendanceButton({required this.icon, required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : color.withOpacity(0.1)),
        ),
        child: Icon(icon, size: 20, color: isSelected ? Colors.white : color),
      ),
    );
  }
}
