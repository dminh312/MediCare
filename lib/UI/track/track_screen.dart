import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:medicare/UI/track/step_screen/step_activity_screen.dart';

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
    final backgroundColor = isDarkMode ? const Color(0xff1a1111) : const Color(0xfffdf8f8);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final borderColor = isDarkMode ? Colors.red.shade900.withAlpha(26) : Colors.red.shade50;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: _buildAppBar(isDarkMode, surfaceColor, borderColor),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StepActivityScreen())),
            child: _buildStepsCard(surfaceColor, borderColor, primaryColor, isDarkMode),
          ),
          const SizedBox(height: 16),
          _buildVitalsGrid(surfaceColor, borderColor, primaryColor, isDarkMode),
          const SizedBox(height: 16),
          _buildWaterIntakeCard(context, surfaceColor, borderColor, primaryColor, isDarkMode),
        ],
      ),
    );
  }

  void _showAddWaterIntakeSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    const primaryColor = Color(0xffff5252);
    final surfaceColor = isDarkMode ? const Color(0xff2d1f1f) : Colors.white;
    final subtleTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            decoration: BoxDecoration(
              color: surfaceColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Add Water Intake', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                        foregroundColor: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _buildWaterQuickAddButton('250ml', Icons.local_drink, isDarkMode, primaryColor),
                    const SizedBox(width: 12),
                    _buildWaterQuickAddButton('500ml', Icons.local_drink, isDarkMode, primaryColor, iconSize: 28),
                    const SizedBox(width: 12),
                    _buildWaterQuickAddButton('750ml', Icons.local_drink, isDarkMode, primaryColor, iconSize: 32),
                  ],
                ),
                const SizedBox(height: 32),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Text('Custom Amount', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: subtleTextColor)),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        hintText: 'Enter amount',
                        suffixText: 'ml',
                        filled: true,
                        fillColor: isDarkMode ? Colors.grey[800]!.withAlpha(128) : Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.add_circle),
                  label: const Text('Add Water'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 64),
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    shadowColor: primaryColor.withAlpha(77),
                    elevation: 5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaterQuickAddButton(String amount, IconData icon, bool isDarkMode, Color primaryColor, {double iconSize = 24.0}) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: isDarkMode ? primaryColor.withAlpha(26) : primaryColor.withAlpha(13),
          side: BorderSide(color: isDarkMode ? primaryColor.withAlpha(102) : primaryColor.withAlpha(51), width: 2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryColor, size: iconSize, fill: 1),
            const SizedBox(height: 8),
            Text(amount, style: TextStyle(color: isDarkMode ? primaryColor.withAlpha(230) : primaryColor, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(bool isDarkMode, Color surfaceColor, Color borderColor) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(100.0),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: AppBar(
            backgroundColor: (isDarkMode ? surfaceColor : Colors.white).withAlpha(204),
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Health Tracking', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 12.0),
                child: IconButton(
                  icon: const Icon(Icons.calendar_today, size: 22),
                  onPressed: () {},
                  style: IconButton.styleFrom(
                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    foregroundColor: isDarkMode ? Colors.grey[200] : Colors.grey[700],
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

  Widget _buildStepsCard(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
    return _buildMetricCard(
      surfaceColor: surfaceColor,
      borderColor: borderColor,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Steps', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
                  const Text('8,432', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                  Text('Goal: 10,000', style: TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.w500)),
                ],
              ),
              SizedBox(
                width: 80,
                height: 80,
                child: _buildStepsRing(0.84, primaryColor, isDarkMode),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildBarChart(primaryColor, isDarkMode),
        ],
      ),
    );
  }
  
  Widget _buildVitalsGrid(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
     return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildHeartRateCard(surfaceColor, borderColor, primaryColor, isDarkMode),
        _buildSleepCard(surfaceColor, borderColor, isDarkMode),
      ],
    );
  }

  Widget _buildStepsRing(double progress, Color primaryColor, bool isDarkMode) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: 80, height: 80,
          child: CircularProgressIndicator(
            value: 1,
            strokeWidth: 6,
            color: isDarkMode ? Colors.grey[800] : Colors.grey[200],
          ),
        ),
        SizedBox(
          width: 80, height: 80,
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
                  color: height == 1.0 ? primaryColor.withAlpha(204) : barColor,
                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(2), topRight: Radius.circular(2)),
                 ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

  Widget _buildHeartRateCard(Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
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
              Text('Heart Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('72', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(width: 4),
              Text('BPM', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
           const SizedBox(height: 12),
           Expanded(
             child: CustomPaint(
                painter: HeartRatePainter(primaryColor),
                size: const Size(double.infinity, double.infinity),
             ),
           ),
        ],
      ),
    );
  }
  
  Widget _buildSleepCard(Color surfaceColor, Color borderColor, bool isDarkMode) {
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
              Text('Sleep', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500])),
            ],
          ),
          const SizedBox(height: 8),
           const Text('7h 20m', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
           const Spacer(),
           ClipRRect(
             borderRadius: BorderRadius.circular(10),
             child: Row(
               children: [
                  Expanded(flex: 3, child: Container(height: 8, color: sleepColor1)),
                  Expanded(flex: 4, child: Container(height: 8, color: sleepColor2)),
                  Expanded(flex: 3, child: Container(height: 8, color: sleepColor3)),
               ],
             ),
           ),
           const SizedBox(height: 8),
           const Text('Deep sleep: 2h 15m', style: TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeCard(BuildContext context, Color surfaceColor, Color borderColor, Color primaryColor, bool isDarkMode) {
  final waterColor = Colors.blue[400];
  final filledIconColor = isDarkMode ? Colors.blue[300] : Colors.blue[500];
  final emptyIconColor = isDarkMode ? Colors.grey[700] : Colors.grey[300];
  final iconBgColor = isDarkMode ? Colors.blue[900]?.withAlpha(102) : Colors.blue[50];

  return _buildMetricCard(
    surfaceColor: surfaceColor,
    borderColor: borderColor,
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(children: [Icon(Icons.water_drop, color: waterColor, size: 20), const SizedBox(width: 8), Text('Water Intake', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey[500]))]),
            const Text('1.2 / 2.5L', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: index < 3 ? iconBgColor : (isDarkMode ? Colors.grey[800] : Colors.grey[100]),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: isDarkMode ? Colors.grey[700]! : Colors.grey[200]!)
                    ),
                    child: Icon(Icons.local_drink, color: index < 3 ? filledIconColor : emptyIconColor, size: 20, fill: 1),
                  );
                }),
              ),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () => _showAddWaterIntakeSheet(context),
              mini: true,
              heroTag: null,
              backgroundColor: primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildMetricCard({required Color surfaceColor, required Color borderColor, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20.0),
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
    path.quadraticBezierTo(size.width * 0.05, size.height * 0.5, size.width * 0.1, size.height * 0.5);
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
