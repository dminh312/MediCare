import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum MedicationType { pill, injection }
enum MedicationStatus { taken, missed, upcoming }

class Medication {
  final String name;
  final String dose;
  final String timing;
  final MedicationType type;
  final MedicationStatus status;
  final TimeOfDay scheduleTime;

  Medication({
    required this.name,
    required this.dose,
    required this.timing,
    required this.type,
    required this.status,
    required this.scheduleTime,
  });
}

class MedsScreen extends StatefulWidget {
  const MedsScreen({super.key});

  @override
  State<MedsScreen> createState() => _MedsScreenState();
}

class _MedsScreenState extends State<MedsScreen> {
  final List<Medication> _morningMeds = [
    Medication(name: 'Vitamin C', dose: '1 Pill', timing: 'After Breakfast', type: MedicationType.pill, status: MedicationStatus.taken, scheduleTime: const TimeOfDay(hour: 8, minute: 0)),
    Medication(name: 'Aspirin', dose: '500mg', timing: 'Before Breakfast', type: MedicationType.pill, status: MedicationStatus.missed, scheduleTime: const TimeOfDay(hour: 7, minute: 30)),
  ];

  final List<Medication> _afternoonMeds = [
    Medication(name: 'Insulin', dose: '10 Units', timing: 'Before Lunch', type: MedicationType.injection, status: MedicationStatus.upcoming, scheduleTime: const TimeOfDay(hour: 12, minute: 30)),
  ];

  final List<Medication> _eveningMeds = [
    Medication(name: 'Magnesium', dose: '250mg', timing: 'Before Bed', type: MedicationType.pill, status: MedicationStatus.upcoming, scheduleTime: const TimeOfDay(hour: 21, minute: 0)),
  ];
  
  int _selectedDayIndex = 2; // Wednesday

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = const Color(0xFFff5252);
    final backgroundColor = isDarkMode ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surfaceColor = isDarkMode ? const Color(0xFF2d1f1f) : Colors.white;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text('My Medications', style: TextStyle(fontWeight: FontWeight.bold, color: isDarkMode ? Colors.white : const Color(0xFF111714))),
        backgroundColor: isDarkMode ? backgroundColor.withOpacity(0.95) : backgroundColor.withOpacity(0.95),
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: isDarkMode ? Colors.transparent : Colors.grey.withOpacity(0.1),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundColor: primaryColor.withOpacity(isDarkMode ? 0.2 : 0.1),
              child: IconButton(
                icon: Icon(Icons.add, color: primaryColor),
                onPressed: () {
                  // TODO: Implement Add Medication
                },
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildDaySelector(),
          const SizedBox(height: 24),
          if (_morningMeds.isNotEmpty) _buildScheduleSection('Morning Schedule', Icons.light_mode, Colors.orange, _morningMeds, surfaceColor),
          if (_afternoonMeds.isNotEmpty) _buildScheduleSection('Afternoon Schedule', Icons.sunny, primaryColor, _afternoonMeds, surfaceColor),
          if (_eveningMeds.isNotEmpty) _buildScheduleSection('Evening Schedule', Icons.dark_mode, Colors.indigo, _eveningMeds, surfaceColor),
        ],
      ),
    );
  }

  Widget _buildDaySelector() {
    final today = DateTime.now();
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 7,
        itemBuilder: (context, index) {
          final day = today.add(Duration(days: index - _selectedDayIndex));
          final isSelected = index == _selectedDayIndex;
          return GestureDetector(
            onTap: () => setState(() => _selectedDayIndex = index),
            child: Container(
              width: 55,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFff5252) : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF2d1f1f) : Colors.white),
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected ? [BoxShadow(color: const Color(0xFFff5252).withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(DateFormat.E().format(day), style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: isSelected ? Colors.white.withOpacity(0.9) : Colors.grey)),
                  const SizedBox(height: 4),
                  Text(day.day.toString(), style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyLarge?.color)),
                  if(isSelected) ...[
                    const SizedBox(height: 4),
                    Container(width: 5, height: 5, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  ]
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildScheduleSection(String title, IconData icon, Color iconColor, List<Medication> meds, Color surfaceColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 16),
          ...meds.map((med) => _buildMedicationItem(med, surfaceColor)),
        ],
      ),
    );
  }

  Widget _buildMedicationItem(Medication med, Color surfaceColor) {
    IconData medIcon;
    Color iconBgColor, iconColor, statusColor;
    String statusText;

    switch (med.type) {
      case MedicationType.pill:
        medIcon = Icons.medication;
        break;
      case MedicationType.injection:
        medIcon = Icons.vaccines;
        break;
    }

    switch (med.status) {
      case MedicationStatus.taken:
        statusText = 'Taken';
        statusColor = Colors.green;
        break;
      case MedicationStatus.missed:
        statusText = 'Missed';
        statusColor = Colors.red;
        break;
      case MedicationStatus.upcoming:
        statusText = 'Upcoming';
        statusColor = Colors.blue;
        break;
    }
    
    iconBgColor = statusColor.withOpacity(0.1);
    iconColor = statusColor;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: med.status == MedicationStatus.missed ? const Border(left: BorderSide(color: Colors.red, width: 4)) : null,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)]
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: iconBgColor,
            child: Icon(medIcon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(med.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text('${med.dose} • ${med.timing}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), 
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(statusText, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 4),
              Text(med.scheduleTime.format(context), style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          )
        ],
      ),
    );
  }
}
