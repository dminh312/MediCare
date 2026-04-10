import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medicare/UI/track/heart_rate/heart_rate_screen.dart';
import 'package:medicare/UI/track/blood_oxygen/blood_oxygen_screen.dart';
import 'package:medicare/UI/components/permission_dialog.dart';
import 'package:medicare/UI/track/sleep_screen/sleep_ana_screen.dart';
import 'package:medicare/UI/track/step_screen/step_activity_screen.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';

class TrackScreen extends StatefulWidget {
  const TrackScreen({super.key});

  @override
  State<TrackScreen> createState() => _TrackScreenState();
}

class _TrackScreenState extends State<TrackScreen> {
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
      appBar: _buildAppBar(isDarkMode, surfaceColor, borderColor),
      body: Consumer<HealthDataViewModel>(
        builder: (context, viewModel, child) {
          final isConnected = viewModel.isConnected;

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              GestureDetector(
                onTap: () {
                  if (isConnected) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const StepActivityScreen(),
                      ),
                    );
                  } else {
                    _showUnauthorizedDialog(context);
                  }
                },
                child: isConnected
                    ? _buildStepsCard(
                        surfaceColor,
                        borderColor,
                        primaryColor,
                        isDarkMode,
                        viewModel.todaySteps,
                        viewModel.stepGoal,
                      )
                    : _buildLockedStepsCard(
                        surfaceColor,
                        borderColor,
                        primaryColor,
                        isDarkMode,
                        viewModel.stepGoal,
                      ),
              ),
              const SizedBox(height: 16),
              _buildVitalsGrid(
                surfaceColor,
                borderColor,
                primaryColor,
                isDarkMode,
                isConnected,
                viewModel.latestHeartRate,
                viewModel.latestBloodOxygen,
                viewModel.sleepDuration,
                viewModel.sleepDeepMinutes,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showUnauthorizedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const PermissionDialog(),
    );
  }

  PreferredSizeWidget _buildAppBar(
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
              'Health Tracking',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today, size: 22),
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: isDarkMode
                        ? Colors.grey[800]
                        : Colors.grey[100],
                    foregroundColor: isDarkMode
                        ? Colors.grey[200]
                        : Colors.grey[700],
                  ),
                ),
              ),
            ],
            shape: Border(bottom: BorderSide(color: borderColor, width: 1.0)),
          ),
        ),
      ),
    );
  }

  Widget _buildStepsCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    int steps,
    int stepGoal,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Steps',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[500],
                      ),
                    ),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '$steps',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      'Goal: ${stepGoal >= 1000 ? '${(stepGoal / 1000).toString().replaceAll(RegExp(r'\\.0\$'), '')}k' : stepGoal}',
                      style: TextStyle(
                        fontSize: 12,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: _buildStepsRing(stepGoal > 0 ? (steps / stepGoal).clamp(0.0, 1.0) : 0.0, primaryColor, isDarkMode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Opacity(
            opacity: steps > 0 ? 1.0 : 0.2,
            child: _buildBarChart(primaryColor, isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedStepsCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    int stepGoal,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Steps',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                              const FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  '...',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Text(
                                'Goal: ${stepGoal >= 1000 ? '${(stepGoal / 1000).toString().replaceAll(RegExp(r'\\.0\$'), '')}k' : stepGoal}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: primaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          width: 80,
                          height: 80,
                          child: _buildStepsRing(0.0, primaryColor, isDarkMode),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildBarChart(primaryColor, isDarkMode),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Locked to Track",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVitalsGrid(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    bool isConnected,
    int heartRate,
    int spO2,
    String sleepDuration,
    int deepSleepMinutes,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        GestureDetector(
          onTap: () {
            if (isConnected) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HeartRateScreen(),
                ),
              );
            } else {
              _showUnauthorizedDialog(context);
            }
          },
          child: isConnected
              ? _buildHeartRateCard(
                  surfaceColor,
                  borderColor,
                  primaryColor,
                  isDarkMode,
                  heartRate,
                )
              : _buildLockedVitalCard(
                  surfaceColor,
                  borderColor,
                  primaryColor,
                  'Heart Rate',
                  Icons.favorite,
                  isDarkMode,
                ),
        ),
        GestureDetector(
          onTap: () {
            if (isConnected) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SleepAnaScreen()),
              );
            } else {
              _showUnauthorizedDialog(context);
            }
          },
          child: isConnected
              ? _buildSleepCard(
                  surfaceColor,
                  borderColor,
                  isDarkMode,
                  sleepDuration,
                  deepSleepMinutes,
                )
              : _buildLockedVitalCard(
                  surfaceColor,
                  borderColor,
                  Colors.indigo[400]!,
                  'Sleep',
                  Icons.bedtime,
                  isDarkMode,
                ),
        ),
        GestureDetector(
          onTap: () {
            if (isConnected) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BloodOxygenScreen()),
              );
            } else {
              _showUnauthorizedDialog(context);
            }
          },
          child: isConnected
              ? _buildSpO2Card(
                  surfaceColor,
                  borderColor,
                  isDarkMode,
                  spO2,
                )
              : _buildLockedVitalCard(
                  surfaceColor,
                  borderColor,
                  Colors.cyan[400]!,
                  'Blood Oxygen',
                  Icons.water_drop,
                  isDarkMode,
                ),
        ),
      ],
    );
  }

  Widget _buildStepsRing(double progress, Color primaryColor, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 6,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
        ),
        SizedBox(
          width: 80,
          height: 80,
          child: CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            strokeCap: StrokeCap.round,
            color: primaryColor,
          ),
        ),
        Icon(Icons.directions_walk, color: primaryColor, size: 28),
      ],
    );
  }

  Widget _buildBarChart(Color primaryColor, bool isDarkMode) {
    final List<double> barHeights = [0.5, 0.66, 0.75, 1.0, 0.66, 0.5, 0.33];
    final barColor = isDarkMode ? primaryColor.withAlpha(51) : Colors.red[100];

    return SizedBox(
      height: 48,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: barHeights.map((height) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: FractionallySizedBox(
                heightFactor: height,
                child: Container(
                  decoration: BoxDecoration(
                    color: height == 1.0
                        ? primaryColor.withAlpha(204)
                        : barColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(2),
                      topRight: Radius.circular(2),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHeartRateCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    bool isDarkMode,
    int heartRate,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: primaryColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Heart Rate',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$heartRate',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 4),
                Text('BPM', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Opacity(
              opacity: heartRate > 0 ? 1.0 : 0.2,
              child: CustomPaint(
                painter: HeartRatePainter(primaryColor),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSleepCard(
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
    String sleepDuration,
    int deepSleepMinutes,
  ) {
    final sleepColor1 = isDarkMode ? Colors.indigo[700] : Colors.indigo[200];
    final sleepColor2 = isDarkMode ? Colors.indigo[500] : Colors.indigo[400];
    final sleepColor3 = isDarkMode ? Colors.indigo[300] : Colors.indigo[600];

    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bedtime, color: Colors.indigo[400], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sleep',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              sleepDuration,
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ),
          const Spacer(),
          Opacity(
            opacity: sleepDuration != "0h 0m" ? 1.0 : 0.2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(height: 8, color: sleepColor1),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(height: 8, color: sleepColor2),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(height: 8, color: sleepColor3),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deep sleep: ${deepSleepMinutes ~/ 60}h ${deepSleepMinutes % 60}m',
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpO2Card(
    Color surfaceColor,
    Color borderColor,
    bool isDarkMode,
    int spO2,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.water_drop, color: Colors.cyan[500], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'SpO2',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[500],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$spO2',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                const Text('%', style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Opacity(
              opacity: spO2 > 0 ? 1.0 : 0.2,
              child: CustomPaint(
                painter: SpO2Painter(Colors.cyan[500]!),
                size: const Size(double.infinity, double.infinity),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedVitalCard(
    Color surfaceColor,
    Color borderColor,
    Color primaryColor,
    String title,
    IconData icon,
    bool isDarkMode,
  ) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: Stack(
          children: [
            ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(icon, color: primaryColor, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '...',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    Container(height: 20),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                color: isDarkMode ? Colors.black.withOpacity(0.4) : Colors.white.withOpacity(0.4),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: isDarkMode ? Colors.white70 : Colors.black54,
                      size: 28,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Locked",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white70 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildMetricCard({
    required Color surfaceColor,
    required Color borderColor,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20.0),
  }) {
    return Container(
      padding: padding,
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

class HeartRatePainter extends CustomPainter {
  final Color color;
  HeartRatePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.05,
      size.height * 0.5,
      size.width * 0.1,
      size.height * 0.5,
    );
    path.lineTo(size.width * 0.15, size.height * 0.5);
    path.lineTo(size.width * 0.18, size.height * 0.25);
    path.lineTo(size.width * 0.22, size.height * 0.875);
    path.lineTo(size.width * 0.26, size.height * 0.5);
    path.lineTo(size.width * 0.4, size.height * 0.5);
    path.lineTo(size.width * 0.45, size.height * 0.125);
    path.lineTo(size.width * 0.5, size.height * 0.95);
    path.lineTo(size.width * 0.55, size.height * 0.5);
    path.lineTo(size.width * 0.70, size.height * 0.5);
    path.lineTo(size.width * 0.75, size.height * 0.375);
    path.lineTo(size.width * 0.80, size.height * 0.625);
    path.lineTo(size.width * 0.85, size.height * 0.5);
    path.lineTo(size.width, size.height * 0.5);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SpO2Painter extends CustomPainter {
  final Color color;
  SpO2Painter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final path = Path();
    path.moveTo(0, size.height * 0.7);
    path.quadraticBezierTo(
      size.width * 0.25,
      size.height * 0.3,
      size.width * 0.5,
      size.height * 0.5,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      size.height * 0.7,
      size.width,
      size.height * 0.3,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
