import 'package:flutter/material.dart';

class SleepSetupScreen extends StatefulWidget {
  const SleepSetupScreen({super.key});

  @override
  State<SleepSetupScreen> createState() => _SleepSetupScreenState();
}

class _SleepSetupScreenState extends State<SleepSetupScreen> {
  static const Color _primary = Color(0xFFff5252);

  TimeOfDay _bedtime = const TimeOfDay(hour: 22, minute: 30);
  TimeOfDay _wakeUpTime = const TimeOfDay(hour: 6, minute: 30);
  bool _alarmEnabled = true;

  final List<String> _days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final Set<int> _selectedDays = {0, 1, 2, 3, 4}; // Mon-Fri

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final initialTime = isBedtime ? _bedtime : _wakeUpTime;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: _primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : const Color(0xFF1a1111), // body text color
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = pickedTime;
        } else {
          _wakeUpTime = pickedTime;
        }
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final amPm = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $amPm';
  }

  String _calculateDuration() {
    int bedMinutes = _bedtime.hour * 60 + _bedtime.minute;
    int wakeMinutes = _wakeUpTime.hour * 60 + _wakeUpTime.minute;

    if (wakeMinutes < bedMinutes) {
      wakeMinutes += 24 * 60; // Next day
    }

    int durationMinutes = wakeMinutes - bedMinutes;
    int hours = durationMinutes ~/ 60;
    int mins = durationMinutes % 60;

    return '${hours}h ${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surface = isDark ? const Color(0xFF2d1f1f) : Colors.white;
    final borderColor = isDark
        ? Colors.red.shade900.withAlpha(26)
        : const Color(0xFFffeaea);
    final subtleText = isDark ? Colors.grey[400]! : const Color(0xFF534343);
    final onSurface = isDark ? Colors.white : const Color(0xFF1a1111);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg.withOpacity(0.95),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Sleep Schedule',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: onSurface,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Sleep Goal ──
            Center(
              child: Column(
                children: [
                  Text(
                    'Target Duration',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subtleText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '8h 00m',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Bedtime Card ──
            _buildTimeCard(
              title: 'Bedtime',
              time: _formatTime(_bedtime),
              icon: Icons.bedtime,
              iconColor: _primary,
              iconBgColor: const Color(0xFFffebee),
              surface: surface,
              borderColor: borderColor,
              onSurface: onSurface,
              subtleText: subtleText,
              onTap: () => _selectTime(context, true),
            ),
            const SizedBox(height: 16),

            // ── Wake-up Time Card ──
            _buildTimeCard(
              title: 'Wake up',
              time: _formatTime(_wakeUpTime),
              icon: Icons.wb_sunny,
              iconColor: Colors.orange,
              iconBgColor: Colors.orange.withOpacity(0.1),
              surface: surface,
              borderColor: borderColor,
              onSurface: onSurface,
              subtleText: subtleText,
              onTap: () => _selectTime(context, false),
              extraWidget: Switch(
                value: _alarmEnabled,
                activeColor: _primary,
                onChanged: (val) {
                  setState(() => _alarmEnabled = val);
                },
              ),
            ),
            const SizedBox(height: 32),

            // ── Repeat Days ──
            Text(
              'Repeat',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(_days.length, (index) {
                final isSelected = _selectedDays.contains(index);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isSelected) {
                        _selectedDays.remove(index);
                      } else {
                        _selectedDays.add(index);
                      }
                    });
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? _primary : surface,
                      border: Border.all(
                        color: isSelected ? _primary : borderColor,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _days[index],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : subtleText,
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // ── Summary Card ──
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Sleep',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: onSurface,
                    ),
                  ),
                  Text(
                    _calculateDuration(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // ── Save Button ──
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate saving
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sleep schedule saved!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Save Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeCard({
    required String title,
    required String time,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required Color surface,
    required Color borderColor,
    required Color onSurface,
    required Color subtleText,
    required VoidCallback onTap,
    Widget? extraWidget,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: subtleText,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: onSurface,
                    ),
                  ),
                ],
              ),
            ),
            if (extraWidget != null) extraWidget,
          ],
        ),
      ),
    );
  }
}
