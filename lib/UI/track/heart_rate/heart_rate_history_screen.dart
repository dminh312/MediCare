import 'package:flutter/material.dart';
import 'package:health/health.dart';
import 'package:medicare/logic/services/health_services.dart';
import 'package:intl/intl.dart';

class HeartRateHistoryScreen extends StatefulWidget {
  const HeartRateHistoryScreen({super.key});

  @override
  State<HeartRateHistoryScreen> createState() => _HeartRateHistoryScreenState();
}

class _DailyHeartRate {
  final DateTime date;
  final int average;
  final int min;
  final int max;
  final List<int> timeline;

  _DailyHeartRate({
    required this.date,
    required this.average,
    required this.min,
    required this.max,
    required this.timeline,
  });
}

class _HeartRateHistoryScreenState extends State<HeartRateHistoryScreen> {
  final HealthService _healthService = HealthService();
  bool _isLoading = true;
  List<_DailyHeartRate> _history = [];

  static const Color _primary = Color(0xFFff5252);
  static const Color _primaryContainer = Color(0xFFffebee);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final now = DateTime.now();
      final data = await _healthService.fetchHeartRate(days: 30);

      Map<String, List<int>> dailyData = {};

      for (var point in data) {
        if (point.value is NumericHealthValue) {
          final val = (point.value as NumericHealthValue).numericValue.round();
          final dateStr = DateFormat('yyyy-MM-dd').format(point.dateFrom);
          
          dailyData.putIfAbsent(dateStr, () => []).add(val);
        }
      }

      List<_DailyHeartRate> processed = [];
      
      dailyData.forEach((dateStr, values) {
        if (values.isNotEmpty) {
          int min = values.reduce((a, b) => a < b ? a : b);
          int max = values.reduce((a, b) => a > b ? a : b);
          int avg = (values.reduce((a, b) => a + b) / values.length).round();
          processed.add(_DailyHeartRate(
            date: DateTime.parse(dateStr),
            average: avg,
            min: min,
            max: max,
            timeline: values.length > 10 ? values.sublist(0, 10) : values,
          ));
        }
      });

      processed.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _history = processed;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching HR history: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1a1111) : const Color(0xFFf7f9fb);
    final surface = isDark ? const Color(0xFF2d1f1f) : Colors.white;
    final subtleText = isDark ? Colors.grey[400]! : const Color(0xFF5b403e);
    final borderColor = isDark ? Colors.red.shade900.withAlpha(26) : const Color(0xFFeceef0);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: bg.withValues(alpha: 0.95),
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF191c1e)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Heart Rate History',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                fontFamily: 'Manrope',
                color: isDark ? Colors.white : const Color(0xFF191c1e),
              ),
            ),
          ),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: _primary)),
            )
          else if (_history.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'No history available',
                  style: TextStyle(color: subtleText, fontSize: 16),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final item = _history[index];
                    return _buildHistoryCard(item, surface, subtleText, borderColor, isDark);
                  },
                  childCount: _history.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(_DailyHeartRate item, Color surface, Color subtleText, Color borderColor, bool isDark) {
    final dateStr = DateFormat('MMM d, yyyy').format(item.date);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191c1e).withAlpha(10),
            blurRadius: 32,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: subtleText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '${item.average} BPM Avg',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatMetric('Min', '${item.min}', subtleText, isDark),
              Container(height: 40, width: 1, color: borderColor),
              _buildStatMetric('Max', '${item.max}', subtleText, isDark),
              Container(height: 40, width: 1, color: borderColor),
              _buildStatMetric('Avg', '${item.average}', subtleText, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, Color subtleText, bool isDark) {
    return Column(
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
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            fontFamily: 'Manrope',
            color: isDark ? Colors.white : const Color(0xFF191c1e),
          ),
        ),
      ],
    );
  }
}
