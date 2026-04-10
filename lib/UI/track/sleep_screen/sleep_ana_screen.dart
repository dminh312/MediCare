import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';
import 'sleep_setup_screen.dart';

class SleepAnaScreen extends StatelessWidget {
  const SleepAnaScreen({super.key});

  static const Color _primary = Color(0xFFff5252);
  static const Color _secondary = Color(0xFFff4081);
  static const Color _secondaryContainer = Color(0xFFffd9e2);

  String _formatDuration(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int mins = totalMinutes % 60;
    if (hours > 0) return '${hours}h ${mins}m';
    return '${mins}m';
  }

  @override
  Widget build(BuildContext context) {
    final healthVM = context.watch<HealthDataViewModel>();

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1a1111) : const Color(0xFFfffbfb);
    final surface = isDark ? const Color(0xFF2d1f1f) : Colors.white;
    final borderColor = isDark
        ? Colors.red.shade900.withAlpha(26)
        : const Color(0xFFffeaea);
    final subtleText = isDark ? Colors.grey[400]! : const Color(0xFF534343);

    int totalDetailed = healthVM.sleepDeepMinutes + healthVM.sleepLightMinutes + healthVM.sleepAwakeMinutes + healthVM.sleepRemMinutes;
    int deepFlex = 30;
    int lightFlex = 55;
    int awakeFlex = 15;

    if (totalDetailed > 0) {
      deepFlex = ((healthVM.sleepDeepMinutes / totalDetailed) * 100).round();
      lightFlex = (((healthVM.sleepLightMinutes + healthVM.sleepRemMinutes) / totalDetailed) * 100).round();
      awakeFlex = ((healthVM.sleepAwakeMinutes / totalDetailed) * 100).round();
      if (deepFlex == 0) deepFlex = 1;
      if (lightFlex == 0) lightFlex = 1;
      if (awakeFlex == 0) awakeFlex = 1;
    }

    String bedtimeStr = "${healthVM.bedtimeHour.padLeft(2, '0')}:${healthVM.bedtimeMinute.padLeft(2, '0')}";
    String wakeupStr = "${healthVM.wakeUpHour.padLeft(2, '0')}:${healthVM.wakeUpMinute.padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Scrollable content
          CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                pinned: true,
                backgroundColor: bg.withOpacity(0.95),
                elevation: 0,
                surfaceTintColor: Colors.transparent,
                shadowColor: _primary.withAlpha(13),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: _primary),
                  onPressed: () => Navigator.of(context).pop(),
                  style: IconButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: Colors.transparent,
                  ),
                ),
                title: Text(
                  'Sleep Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1a1111),
                  ),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.share, color: _primary),
                    onPressed: () {},
                    style: IconButton.styleFrom(shape: const CircleBorder()),
                  ),
                  const SizedBox(width: 8),
                ],
              ),

              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // ── Duration & Status Card ──
                    _buildCard(
                      surface: surface,
                      border: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Duration',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: subtleText,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _primary.withAlpha(26),
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      color: _primary,
                                      size: 14,
                                      fill: 1,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      healthVM.sleepScore >= 80 ? 'GOOD' : (healthVM.sleepScore >= 60 ? 'FAIR' : 'POOR'),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _primary,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            healthVM.sleepDuration,
                            style: TextStyle(
                              fontSize: 42,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? Colors.white
                                  : const Color(0xFF1a1111),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            healthVM.sleepScore >= 80 ? 'Total sleep time is optimal.' : 'Consider adjusting your sleep schedule.',
                            style: TextStyle(fontSize: 13, color: subtleText),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Sleep Stages + Quality Score Row ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Sleep Stages
                        Expanded(
                          child: _buildCard(
                            surface: surface,
                            border: borderColor,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Sleep Stages',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1a1111),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Stacked bar
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(999),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: deepFlex,
                                        child: Container(
                                          height: 32,
                                          color: _primary,
                                        ),
                                      ),
                                      Expanded(
                                        flex: lightFlex,
                                        child: Container(
                                          height: 32,
                                          color: _secondary,
                                        ),
                                      ),
                                      Expanded(
                                        flex: awakeFlex,
                                        child: Container(
                                          height: 32,
                                          color: _secondaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildStageLegend(
                                  Colors.red.shade400,
                                  'Deep Sleep',
                                  _formatDuration(healthVM.sleepDeepMinutes),
                                  subtleText,
                                ),
                                const SizedBox(height: 10),
                                _buildStageLegend(
                                  _secondary,
                                  'Light Sleep',
                                  _formatDuration(healthVM.sleepLightMinutes + healthVM.sleepRemMinutes),
                                  subtleText,
                                ),
                                const SizedBox(height: 10),
                                _buildStageLegend(
                                  isDark
                                      ? Colors.pink.shade900
                                      : Colors.pink.shade100,
                                  'Awake',
                                  _formatDuration(healthVM.sleepAwakeMinutes),
                                  subtleText,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Quality Score
                        Expanded(
                          child: _buildCard(
                            surface: surface,
                            border: borderColor,
                            child: Column(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 120,
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CircularProgressIndicator(
                                          value: 1,
                                          strokeWidth: 8,
                                          color: isDark
                                              ? Colors.grey[800]
                                              : Colors.grey[200],
                                        ),
                                      ),
                                      SizedBox(
                                        width: 120,
                                        height: 120,
                                        child: CircularProgressIndicator(
                                          value: healthVM.sleepScore / 100,
                                          strokeWidth: 8,
                                          strokeCap: StrokeCap.round,
                                          color: _primary,
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            healthVM.sleepScore.toString(),
                                            style: TextStyle(
                                              fontSize: 30,
                                              fontWeight: FontWeight.w800,
                                              color: isDark
                                                  ? Colors.white
                                                  : const Color(0xFF1a1111),
                                            ),
                                          ),
                                          Text(
                                            'SCORE',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color: subtleText,
                                              letterSpacing: 1.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF1a1111),
                                      height: 1.5,
                                    ),
                                    children: [
                                      const TextSpan(text: 'You slept better than '),
                                      TextSpan(
                                        text: '${healthVM.sleepScore}%',
                                        style: const TextStyle(
                                          color: _primary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const TextSpan(
                                        text: ' of users in your demographic.',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Schedule Card ──
                    _buildCard(
                      surface: surface,
                      border: borderColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Schedule',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : const Color(0xFF1a1111),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: _primary, size: 20),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const SleepSetupScreen(),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Dashed line
                              Positioned.fill(
                                child: Center(
                                  child: FractionallySizedBox(
                                    widthFactor: 0.6,
                                    child: CustomPaint(
                                      painter: _DashedLinePainter(
                                        color: isDark
                                            ? Colors.grey[700]!
                                            : const Color(0xFFd8c2c2),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildScheduleItem(
                                    icon: Icons.bedtime,
                                    label: 'BEDTIME',
                                    time: bedtimeStr,
                                    bgColor: const Color(0xFFffebee),
                                    iconColor: _primary,
                                    surface: surface,
                                    isDark: isDark,
                                    subtleText: subtleText,
                                  ),
                                  _buildScheduleItem(
                                    icon: Icons.wb_sunny,
                                    label: 'WAKE UP',
                                    time: wakeupStr,
                                    bgColor: _secondaryContainer,
                                    iconColor: _secondary,
                                    surface: surface,
                                    isDark: isDark,
                                    subtleText: subtleText,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // ── Sleeping Heart Rate Card ──
                    if (healthVM.sleepingHeartRateAvg > 0)
                      _buildCard(
                        surface: surface,
                        border: borderColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Sleeping Heart Rate',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF1a1111),
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.favorite,
                                      color: _primary,
                                      size: 16,
                                      fill: 1,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${healthVM.sleepingHeartRateAvg} BPM',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            _SleepHeartRateChart(isDark: isDark, heights: healthVM.sleepingHeartRateChart),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Start',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: subtleText,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'Mid',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: subtleText,
                                    letterSpacing: 1,
                                  ),
                                ),
                                Text(
                                  'End',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: subtleText,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    
                    if (healthVM.sleepingHeartRateAvg > 0) const SizedBox(height: 16),

                    // ── Expert Insight Card ──
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: _primary.withAlpha(51),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -30,
                            bottom: -30,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withAlpha(26),
                              ),
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.lightbulb,
                                color: Colors.white,
                                size: 30,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Expert Insight',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      'Your consistency in bedtime over the last 3 days has significantly improved your Deep Sleep ratio. Maintain this rhythm for better cognitive focus tomorrow.',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 13,
                                        height: 1.6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required Color surface,
    required Color border,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildStageLegend(
    Color dot,
    String label,
    String value,
    Color subtleText,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(label, style: TextStyle(fontSize: 12, color: subtleText)),
          ],
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildScheduleItem({
    required IconData icon,
    required String label,
    required String time,
    required Color bgColor,
    required Color iconColor,
    required Color surface,
    required bool isDark,
    required Color subtleText,
  }) {
    return Container(
      color: surface,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: subtleText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1a1111),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Heart Rate Bar Chart ──
class _SleepHeartRateChart extends StatelessWidget {
  final bool isDark;
  final List<double> heights;
  const _SleepHeartRateChart({required this.isDark, required this.heights});

  @override
  Widget build(BuildContext context) {
    List<double> displayHeights = heights.isNotEmpty ? heights : List.filled(16, 0.1);
    
    return SizedBox(
      height: 96,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: displayHeights.map((h) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FractionallySizedBox(
                alignment: Alignment.bottomCenter,
                heightFactor: h,
                child: Container(
                  decoration: BoxDecoration(
                    color: h >= 0.70
                        ? SleepAnaScreen._primary.withAlpha(77)
                        : SleepAnaScreen._primary.withAlpha(26),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(4),
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
}

// ── Dashed Line Painter ──
class _DashedLinePainter extends CustomPainter {
  final Color color;
  const _DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(x + 6, size.height / 2),
        paint,
      );
      x += 12;
    }
  }

  @override
  bool shouldRepaint(_DashedLinePainter old) => old.color != color;
}
