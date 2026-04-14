import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';
class StepActivityScreen extends StatefulWidget {
  const StepActivityScreen({super.key});

  @override
  State<StepActivityScreen> createState() => _StepActivityScreenState();
}

class _StepActivityScreenState extends State<StepActivityScreen> {
  int _sedentaryInterval = 60;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sedentaryInterval = prefs.getInt('sedentaryInterval') ?? 60;
    });
  }

  Future<void> _saveInterval(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('sedentaryInterval', value);
    setState(() {
      _sedentaryInterval = value;
    });
  }

  void _showEditGoalBottomSheet() {
    final viewModel = Provider.of<HealthDataViewModel>(context, listen: false);
    final controller = TextEditingController(text: viewModel.stepGoal.toString());
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final primaryColor = const Color(0xffff5252);
        final surfaceColor = isDarkMode ? const Color(0xff1a1111) : Colors.white;
        final textColor = isDarkMode ? Colors.white : const Color(0xff1a1111);
        final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Target Setting',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: primaryColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Set New Goal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withAlpha(25),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.flag_rounded, color: primaryColor, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Input Field
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[900] : Colors.grey[50],
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                            letterSpacing: -1.5,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: '10000',
                            hintStyle: TextStyle(
                              color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                            ),
                          ),
                        ),
                      ),
                      Text(
                        'steps',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: subtitleColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
                            ),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: subtitleColor,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final newGoal = int.tryParse(controller.text);
                          if (newGoal != null && newGoal > 0) {
                            viewModel.updateStepGoal(newGoal);
                          }
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Save Goal',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Contextual Tip
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withAlpha(25),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.lightbulb_outline, color: Colors.amber[700], size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Setting a realistic goal helps you stay motivated consistently.',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDarkMode ? Colors.amber[100] : Colors.amber[900],
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final backgroundColor = isDarkMode
        ? const Color(0xff1a1111)
        : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode
        ? Colors.red.shade900.withAlpha(26)
        : Colors.red.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(context, isDarkMode, surfaceColor, borderColor),
      body: Consumer<HealthDataViewModel>(
        builder: (context, viewModel, child) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildTodayProgressCard(
                surfaceColor,
                borderColor,
                primaryColor,
                isDarkMode,
                viewModel.todaySteps,
                viewModel.stepGoal,
              ),
              const SizedBox(height: 24),
          _buildWeeklyActivityCard(
            surfaceColor,
            borderColor,
            primaryColor,
            isDarkMode,
            viewModel,
          ),
          const SizedBox(height: 24),
          _buildInsightsSection(
            surfaceColor,
            borderColor,
            primaryColor,
            isDarkMode,
            viewModel,
          ),
        ],
      );
    }),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    bool isDarkMode,
    Color surfaceColor,
    Color borderColor,
  ) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: (isDarkMode ? surfaceColor : Colors.white)
                .withAlpha(204),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text(
              'Steps Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.of(context).pop(),
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    isDarkMode ? Colors.grey[800] : Colors.grey[100],
                  ),
                  foregroundColor: WidgetStateProperty.all(
                    isDarkMode ? Colors.grey[200] : Colors.grey[700],
                  ),
                ),
              ),
            ),
            shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildTodayProgressCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    int todaySteps,
    int stepGoal,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Today\'s Progress',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                todaySteps.toString(),
                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _showEditGoalBottomSheet,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? primaryColor.withAlpha(26)
                        : const Color(0xFFffebee),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.flag, color: primaryColor, size: 16, fill: 1),
                      const SizedBox(width: 6),
                      Text(
                        'Goal: $stepGoal',
                        style: TextStyle(
                          fontSize: 14,
                          color: primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        color: primaryColor.withAlpha(178),
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            width: 112,
            height: 112,
            child: _buildProgressRing(
              stepGoal > 0 ? todaySteps / stepGoal : 0.0,
              primaryColor,
              isDarkMode,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressRing(
    double progress,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 112,
          height: 112,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 8,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          ),
        ),
        SizedBox(
          width: 112,
          height: 112,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 8,
            strokeCap: StrokeCap.round,
            color: primaryColor,
          ),
        ),
        Text(
          '${(progress * 100).toInt()}%',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWeeklyActivityCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    HealthDataViewModel viewModel,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weekly Activity',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Chip(
                label: const Text('Last 7 Days'),
                labelStyle: TextStyle(fontSize: 12, color: Colors.grey[500]),
                backgroundColor: isDarkMode
                    ? Colors.grey[800]
                    : Colors.grey[50],
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildWeeklyBarChart(primaryColor, isDarkMode, viewModel),
        ],
      ),
    );
  }

  Widget _buildWeeklyBarChart(Color primaryColor, bool isDarkMode, HealthDataViewModel viewModel) {
    List<int> weeklySteps = viewModel.weeklyStepsChart;
    int maxSteps = weeklySteps.reduce((curr, next) => curr > next ? curr : next);
    if (maxSteps < 100) maxSteps = 100; // prevent divide by zero and tiny graphs

    final List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    // Assuming the 7th element is today, we need to map back to weekday names dynamically if we want.
    // For simplicity, we just use the last 7 days.
    List<Map<String, dynamic>> weeklyData = [];
    final now = viewModel.targetDate;
    for (int i = 0; i < 7; i++) {
      int steps = weeklySteps[i];
      DateTime date = now.subtract(Duration(days: 6 - i));
      String dayName = days[date.weekday - 1];
      double heightOffset = steps / maxSteps;
      bool isToday = (i == 6);
      weeklyData.add({
        'day': dayName,
        'height': heightOffset,
        'color': isToday ? primaryColor : (isDarkMode ? Colors.red[900]!.withAlpha(51) : Colors.red[100]),
        'steps': steps,
      });
    }

    return SizedBox(
      height: 192,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: weeklyData.map((data) {
          bool isToday = data['color'] == primaryColor;
          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isToday) ...[
                  Text(
                    '${data['steps']}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                ] else ...[
                  const SizedBox(height: 18),
                ],
                Flexible(
                  child: FractionallySizedBox(
                    heightFactor: data['height'],
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: data['color'],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(6),
                          topRight: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data['day'],
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isToday
                        ? primaryColor
                        : Colors.grey[400],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInsightsSection(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    HealthDataViewModel viewModel,
  ) {
    int sum = viewModel.weeklyStepsChart.reduce((a, b) => a + b);
    int avg = (sum / 7).round();
    double distanceKm = viewModel.todaySteps * 0.76 / 1000;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
          child: Text(
            'Insights',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          children: [
            _buildInsightCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              icon: Icons.speed,
              iconColor: primaryColor,
              iconBgColor: isDarkMode
                  ? primaryColor.withAlpha(51)
                  : Colors.red[50],
              title: 'Weekly Average',
              value: '$avg',
              subtitle: 'From last 7 days',
              subtitleColor: Colors.green[500],
            ),
            _buildInsightCard(
              surfaceColor: surfaceColor,
              borderColor: borderColor,
              icon: Icons.timeline,
              iconColor: Colors.blue,
              iconBgColor: isDarkMode
                  ? Colors.blue[900]!.withAlpha(102)
                  : Colors.blue[50],
              title: 'Today Distance',
              value: '${distanceKm.toStringAsFixed(1)} km',
              subtitle: '0.76m avg stride',
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSedentaryReminderCard(surfaceColor, borderColor, primaryColor, isDarkMode),
        const SizedBox(height: 16),
        _buildStreakCard(primaryColor, isDarkMode, viewModel),
      ],
    );
  }

  Widget _buildSedentaryReminderCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
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
              color: isDarkMode
                  ? Colors.blue.shade900.withAlpha(51)
                  : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.airline_seat_recline_normal, color: Colors.blue.shade500),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sedentary Reminder',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  'Remind to move',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              value: _sedentaryInterval,
              dropdownColor: surfaceColor,
              icon: Icon(Icons.arrow_drop_down, color: isDarkMode ? Colors.white : Colors.black87),
              onChanged: (val) {
                if (val != null) _saveInterval(val);
              },
              items: [30, 45, 60, 90, 120].map((int val) {
                return DropdownMenuItem<int>(
                  value: val,
                  child: Text(
                    '$val mins',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black87,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required Color surfaceColor,
    required Color borderColor,
    required IconData icon,
    required Color iconColor,
    Color? iconBgColor,
    required String title,
    required String value,
    required String subtitle,
    Color? subtitleColor,
  }) {
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
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: subtitleColor ?? Colors.grey[400],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(Color primaryColor, bool isDarkMode, HealthDataViewModel viewModel) {
    int stepGoal = viewModel.stepGoal;
    int todaySteps = viewModel.todaySteps;
    int remaining = stepGoal - todaySteps;
    String subtitleText = remaining > 0 
        ? "Keep going! You're only $remaining steps away from your goal."
        : "You've reached your step goal today!";

    int streak = 0;
    for (int i = 6; i >= 0; i--) {
      if (viewModel.weeklyStepsChart[i] >= stepGoal) {
        streak++;
      } else if (i < 6) {
        break;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode
            ? Colors.red[900]!.withAlpha(26)
            : primaryColor.withAlpha(10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDarkMode ? const Color(0xff2d1f1f) : Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.emoji_events, color: primaryColor, fill: 1),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Daily Streak: $streak Days',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitleText,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required Color surfaceColor,
    required Color borderColor,
    required Widget child,
    EdgeInsets? padding,
  }) {
    return Container(
      padding: padding ?? const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor, width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
