import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StepActivityScreen extends StatefulWidget {
  const StepActivityScreen({super.key});

  @override
  State<StepActivityScreen> createState() => _StepActivityScreenState();
}

class _StepActivityScreenState extends State<StepActivityScreen> {
  int _stepGoal = 10000;

  void _showEditGoalDialog() {
    final controller = TextEditingController(text: _stepGoal.toString());
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Set New Goal'),
          content: TextField(
            controller: controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(hintText: 'Enter your new step goal'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final newGoal = int.tryParse(controller.text);
                if (newGoal != null && newGoal > 0) {
                  setState(() {
                    _stepGoal = newGoal;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode, surfaceColor, borderColor),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildTodayProgressCard(surfaceColor, borderColor, primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildWeeklyActivityCard(surfaceColor, borderColor, primaryColor, isDarkMode),
          const SizedBox(height: 24),
          _buildInsightsSection(surfaceColor, borderColor, primaryColor, isDarkMode),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, bool isDarkMode, Color surfaceColor, Color borderColor) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withAlpha(204),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Steps Activity', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                 style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                  foregroundColor: MaterialStateProperty.all(isDarkMode ? Colors.grey[200] : Colors.grey[700]),
                ),
              ),
            ),
            shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayProgressCard(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Today\'s Progress', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
              const SizedBox(height: 4),
              const Text('8,432', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showEditGoalDialog,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDarkMode ? primaryColor.withAlpha(26) : const Color(0xFFffebee),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: primaryColor, size: 16, fill: 1),
                      const SizedBox(width: 6),
                      Text('Goal: $_stepGoal', style: TextStyle(fontSize: 14, color: primaryColor, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 4),
                      Icon(Icons.edit, color: primaryColor.withAlpha(178), size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 112,
            height: 112,
            child: _buildProgressRing(8432 / _stepGoal, primaryColor, isDarkMode),
          ),
        ],
      ),
    );
  }

 Widget _buildProgressRing(double progress, Color primaryColor, bool isDarkMode) {
  return Stack(
    alignment: Alignment.center,
    children: [
      SizedBox(
        width: 112, height: 112,
        child: CircularProgressIndicator(
          value: 1,
          strokeWidth: 8,
          color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
        ),
      ),
      SizedBox(
        width: 112, height: 112,
        child: CircularProgressIndicator(
          value: progress,
          strokeWidth: 8,
          strokeCap: StrokeCap.round,
          color: primaryColor,
        ),
      ),
      Text('${(progress * 100).toInt()}%', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    ],
  );
}


  Widget _buildWeeklyActivityCard(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Weekly Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Chip(
                label: const Text('Last 7 Days'),
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
                backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[50],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWeeklyBarChart(primaryColor, isDarkMode),
        ],
      ),
    );
  }
  
  Widget _buildWeeklyBarChart(Color primaryColor, bool isDarkMode) {
    final List<Map<String, dynamic>> weeklyData = [
      {'day': 'Mon', 'height': 0.60, 'color': isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]},
      {'day': 'Tue', 'height': 0.45, 'color': isDarkMode ? Colors.red[800]!.withAlpha(102) : Colors.red[200]},
      {'day': 'Wed', 'height': 0.85, 'color': isDarkMode ? Colors.red[700]!.withAlpha(128) : Colors.red[300]},
      {'day': 'Thu', 'height': 0.35, 'color': primaryColor.withAlpha(102)},
      {'day': 'Fri', 'height': 0.70, 'color': primaryColor.withAlpha(153)},
      {'day': 'Sat', 'height': 0.95, 'color': primaryColor.withAlpha(204)},
      {'day': 'Sun', 'height': 0.84, 'color': primaryColor},
    ];

    return SizedBox(
      height: 192,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weeklyData.map((data) {
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: data['height'],
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: data['color'],
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(6), topRight: Radius.circular(6)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['day'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: data['day'] == 'Sun' ? FontWeight.bold : FontWeight.normal,
                    color: data['day'] == 'Sun' ? primaryColor : Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
  
  Widget _buildInsightsSection(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text('Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.2,
          children: [
            _buildInsightCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              icon: Icons.speed,
              iconColor: primaryColor,
              iconBgColor: isDarkMode ? primaryColor.withAlpha(51) : Colors.red[50],
              title: 'Weekly Average',
              value: '7,124',
              subtitle: '↑ 12% vs last week',
              subtitleColor: Colors.green[500],
            ),
            _buildInsightCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              icon: Icons.timeline,
              iconColor: Colors.blue,
              iconBgColor: isDarkMode ? Colors.blue[900]!.withAlpha(102) : Colors.blue[50],
              title: 'Total Distance',
              value: '5.2 km',
              subtitle: '7,400 steps avg/km',
            ),
          ],
        ),
         const SizedBox(height: 16),
        _buildStreakCard(primaryColor, isDarkMode),
      ],
    );
  }
  
  Widget _buildInsightCard({required Color surfaceColor, required Color borderColor, required IconData icon, required Color iconColor, Color? iconBgColor, required String title, required String value, required String subtitle, Color? subtitleColor}) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: iconBgColor, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.grey[500])),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, color: subtitleColor ?? Colors.grey[400], fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
  
  Widget _buildStreakCard(Color primaryColor, bool isDarkMode) {
     return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red[900]!.withAlpha(26) : primaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: primaryColor, fill: 1),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Streak: 5 Days', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                SizedBox(height: 2),
                Text('Keep going! You\'re only 1,568 steps away from your goal.', style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMetricCard({required Color surfaceColor, required Color borderColor, required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: child,
    );
  }
}
