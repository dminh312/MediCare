import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:medicare/logic/services/health_services.dart';
import 'package:medicare/UI/track/heart_rate/heart_rate_history_screen.dart';
import 'package:provider/provider.dart';
import 'package:medicare/logic/viewmodels/health_data_viewmodel.dart';

class HeartRateScreen extends StatefulWidget {
  const HeartRateScreen({super.key});

  @override
  State<HeartRateScreen> createState() => _HeartRateScreenState();
}

class _HeartRateScreenState extends State<HeartRateScreen>
    with TickerProviderStateMixin {
  late final AnimationController _pingController;
  late final AnimationController _ecgController;
  late final Animation<double> _ecgAnimation;

  final HealthService _healthService = HealthService();
  bool _isLoading = true;
  int _currentHr = 0;
  int _minHr = 0;
  int _maxHr = 0;
  int _restHr = 0;
  List<double> _trendHeights = List.filled(7, 0.1);
  List<String> _trendDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  List<int> _trendValues = List.filled(7, 0);

  static const Color _primary = Color(0xFFff5252);
  static const Color _secondary = Color(0xFFff4081);
  static const Color _tertiary = Color(0xFF7e5700);
  static const Color _primaryContainer = Color(0xFFffebee);
  static const Color _primaryFixedDim = Color(0xFFffb4ab);
  static const Color _tertiaryFixed = Color(0xFFffdf9e);

  @override
  void initState() {
    super.initState();
    _pingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _ecgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    _ecgAnimation = Tween<double>(begin: 0, end: 1).animate(_ecgController);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final viewModel = Provider.of<HealthDataViewModel>(context, listen: false);
      final targetDate = viewModel.targetDate;
      final realNow = DateTime.now();
      final isToday = targetDate.year == realNow.year && targetDate.month == realNow.month && targetDate.day == realNow.day;
      
      final endOfDay = isToday ? realNow : DateTime(targetDate.year, targetDate.month, targetDate.day, 23, 59, 59);
      final now = endOfDay;

      final data = await _healthService.fetchHeartRate(days: 7);
      if (data.isNotEmpty) {
        data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
        
        final latestPoint = data.first;
        if (latestPoint.value is NumericHealthValue) {
          _currentHr = (latestPoint.value as NumericHealthValue).numericValue.round();
        }

        int minHr = 999;
        int maxHr = 0;
        int sumHr = 0;
        int countHr = 0;

        Map<int, List<int>> dailyHrs = {};
        final startOfDay = DateTime(now.year, now.month, now.day);

        for (var point in data) {
          if (point.value is NumericHealthValue) {
            final val = (point.value as NumericHealthValue).numericValue.round();
            
            final isToday = point.dateFrom.isAfter(startOfDay) || point.dateFrom.isAtSameMomentAs(startOfDay);
            if (isToday) {
              if (val < minHr) minHr = val;
              if (val > maxHr) maxHr = val;
              sumHr += val;
              countHr++;
            }

            final dayStart = DateTime(point.dateFrom.year, point.dateFrom.month, point.dateFrom.day);
            final daysAgo = startOfDay.difference(dayStart).inDays;
            
            if (daysAgo >= 0 && daysAgo < 7) {
              dailyHrs.putIfAbsent(daysAgo, () => []).add(val);
            }
          }
        }

        _minHr = minHr == 999 ? 0 : minHr;
        _maxHr = maxHr;
        _restHr = countHr > 0 ? (sumHr / countHr).round() : 0; 
        if (_minHr > 0 && _restHr == 0) _restHr = _minHr + 4;

        List<double> heights = List.filled(7, 0.1);
        List<String> days = List.filled(7, '');
        final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

        int maxDailyAvg = 1;
        List<int> dailyAvgs = List.filled(7, 0);
        List<int> values = List.filled(7, 0);

        for (int i = 6; i >= 0; i--) {
          final targetDate = now.subtract(Duration(days: i));
          days[6 - i] = weekDays[targetDate.weekday - 1];

          final list = dailyHrs[i] ?? [];
          if (list.isNotEmpty) {
            final avg = (list.reduce((a, b) => a + b) / list.length).round();
            dailyAvgs[6 - i] = avg;
            values[6 - i] = avg;
            if (avg > maxDailyAvg) {
              maxDailyAvg = avg;
            }
          }
        }

        for (int i = 0; i < 7; i++) {
          if (dailyAvgs[i] > 0) {
            heights[i] = (dailyAvgs[i] / maxDailyAvg).clamp(0.1, 1.0);
          }
        }

        setState(() {
          _trendDays = days;
          _trendHeights = heights;
          _trendValues = values;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error fetching HR: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _pingController.dispose();
    _ecgController.dispose();
    super.dispose();
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

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ──
          SliverAppBar(
            pinned: true,
            backgroundColor: bg.withValues(alpha: 0.95),
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            shadowColor: _primary.withAlpha(13),
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: isDark ? Colors.white : const Color(0xFF1a1111),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Heart Rate',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1a1111),
              ),
            ),
            actions: [
              Icon(Icons.notifications_none, color: _primary),
              const SizedBox(width: 16),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            sliver: _isLoading 
              ? const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 100),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                )
              : SliverList(
              delegate: SliverChildListDelegate([
                // ── Hero: Current Heart Rate Card ──
                _buildHeroCard(isDark, surface, borderColor),
                const SizedBox(height: 16),

                // ── Real-time ECG Waveform ──
                _buildEcgCard(isDark, surface, borderColor),
                const SizedBox(height: 16),

                // ── Stats Row: Min / Max / Rest ──
                _buildStatsRow(isDark, surface, borderColor, subtleText),
                const SizedBox(height: 16),

                // ── 7-Day Trend Chart ──
                _buildTrendCard(isDark, surface, borderColor, subtleText),
                const SizedBox(height: 16),

                // ── Intensity Zones ──
                _buildZonesCard(isDark, surface, borderColor, subtleText),
                const SizedBox(height: 16),

                // ── Vitality Tip ──
                _buildTipCard(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroCard(bool isDark, Color surface, Color border) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
      decoration: _cardDecoration(surface, border),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Decorative circle top-right
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _primary.withAlpha(13),
              ),
            ),
          ),
          Column(
            children: [
              // Pulsing heart icon
              Stack(
                alignment: Alignment.center,
                children: [
                  ScaleTransition(
                    scale: Tween<double>(begin: 1.0, end: 1.6).animate(
                      CurvedAnimation(
                        parent: _pingController,
                        curve: Curves.easeOut,
                      ),
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.4, end: 0.0).animate(
                        CurvedAnimation(
                          parent: _pingController,
                          curve: Curves.easeOut,
                        ),
                      ),
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _primary.withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: 72,
                    height: 72,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _primaryContainer,
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: _primary,
                      size: 36,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // BPM display
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    '$_currentHr',
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -2,
                      color: isDark ? Colors.white : const Color(0xFF1a1111),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _primary,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                'CURRENT PULSE • JUST NOW',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: const Color(0xFF534343).withAlpha(180),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Animated ECG waveform card
  // ─────────────────────────────────────────
  Widget _buildEcgCard(bool isDark, Color surface, Color border) {
    final bgLow = isDark ? const Color(0xFF3a2020) : const Color(0xFFfff5f5);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(surface, border),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ECG Waveform',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1a1111),
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
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 88,
            decoration: BoxDecoration(
              color: bgLow,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedBuilder(
              animation: _ecgAnimation,
              builder: (context, _) {
                return CustomPaint(
                  painter: _EcgPainter(
                    progress: _ecgAnimation.value,
                    color: _primary,
                  ),
                  size: const Size(double.infinity, 88),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Min / Max / Rest stats
  // ─────────────────────────────────────────
  Widget _buildStatsRow(
    bool isDark,
    Color surface,
    Color border,
    Color subtleText,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isDark,
            surface,
            border,
            subtleText,
            'MIN',
            '$_minHr',
            _primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            surface,
            border,
            subtleText,
            'MAX',
            '$_maxHr',
            _secondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            isDark,
            surface,
            border,
            subtleText,
            'REST',
            '$_restHr',
            _tertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    bool isDark,
    Color surface,
    Color border,
    Color subtleText,
    String label,
    String value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        border: Border(left: BorderSide(color: accent, width: 4)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(8),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: subtleText,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1a1111),
                ),
              ),
              const SizedBox(width: 2),
              Text(
                'BPM',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: accent,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 7-Day Trend bar chart
  // ─────────────────────────────────────────
  Widget _buildTrendCard(
    bool isDark,
    Color surface,
    Color border,
    Color subtleText,
  ) {
    final days = _trendDays;
    final heights = _trendHeights;
    final activeIdx = 6; // Today

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(surface, border),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '7-Day Trend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF1a1111),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HeartRateHistoryScreen(),
                    ),
                  );
                },
                style: TextButton.styleFrom(
                  foregroundColor: _primary,
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  'FULL HISTORY',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(days.length, (i) {
                final isActive = i == activeIdx;
                int val = _trendValues[i];
                int maxVal = _trendValues.isNotEmpty ? _trendValues.reduce((a, b) => a > b ? a : b) : 0;
                bool isHighest = val > 0 && val == maxVal;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (isHighest) ...[
                        Text(
                          '$val',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ] else ...[
                        const SizedBox(height: 18),
                      ],
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOut,
                        width: 10,
                        height: 90 * heights[i],
                        decoration: BoxDecoration(
                          color: isActive ? _primary : _primaryContainer,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        days[i],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? _primary : subtleText,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Intensity Zones progress bars
  // ─────────────────────────────────────────
  Widget _buildZonesCard(
    bool isDark,
    Color surface,
    Color border,
    Color subtleText,
  ) {
    final zones = [
      ('Resting (0–60)', 0.65, _primaryFixedDim),
      ('Warm-up (60–100)', 0.20, _tertiaryFixed),
      ('Cardio (100–140)', 0.12, _primary),
      ('Peak (140+)', 0.03, _secondary),
    ];
    final trackColor = isDark
        ? const Color(0xFF3a2020)
        : const Color(0xFFfff5f5);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: _cardDecoration(surface, border),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Intensity Zones',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1a1111),
            ),
          ),
          const SizedBox(height: 20),
          ...zones.map((z) {
            final (label, fraction, color) = z;
            final pct = '${(fraction * 100).toInt()}%';
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1,
                          color: subtleText,
                        ),
                      ),
                      Text(
                        pct,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF1a1111),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: Stack(
                      children: [
                        Container(height: 8, color: trackColor),
                        FractionallySizedBox(
                          widthFactor: fraction,
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // Vitality Tip card
  // ─────────────────────────────────────────
  Widget _buildTipCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _primary.withAlpha(64),
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
            child: Icon(
              Icons.lightbulb,
              size: 120,
              color: Colors.white.withAlpha(26),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Vitality Tip',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Your resting heart rate is 5% lower than last week. This indicates improved cardiovascular recovery. Keep up the consistent sleep schedule to maintain this progress!',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 13,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration(Color surface, Color border) {
    return BoxDecoration(
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
    );
  }
}

class _EcgPainter extends CustomPainter {
  final double progress; // 0.0 → 1.0
  final Color color;

  const _EcgPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // ECG control points (normalised 0–1 in both axes)
    final pts = [
      Offset(0.00, 0.50),
      Offset(0.12, 0.50),
      Offset(0.15, 0.20), // P wave up
      Offset(0.18, 0.80), // P wave down
      Offset(0.20, 0.50),
      Offset(0.32, 0.50),
      Offset(0.35, 0.10), // QRS up
      Offset(0.38, 0.90), // QRS down
      Offset(0.40, 0.50),
      Offset(0.52, 0.50),
      Offset(0.55, 0.20),
      Offset(0.57, 0.80),
      Offset(0.60, 0.50),
      Offset(0.72, 0.50),
      Offset(0.75, 0.10),
      Offset(0.78, 0.90),
      Offset(0.80, 0.50),
      Offset(1.00, 0.50),
    ];

    final path = Path();
    if (pts.isEmpty) return;

    final totalLength = size.width;
    final revealX = progress * totalLength;

    path.moveTo(pts.first.dx * size.width, pts.first.dy * size.height);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx * size.width, pts[i].dy * size.height);
    }

    // Clip to reveal only up to `revealX` (trailing wipe).
    final clip = Path()..addRect(Rect.fromLTWH(0, 0, revealX, size.height));

    canvas.clipPath(clip);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_EcgPainter old) =>
      old.progress != progress || old.color != color;
}
