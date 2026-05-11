import 'package:ai_fitness_coach/models/workout_progress_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class ProgressOverviewSection extends StatelessWidget {
  const ProgressOverviewSection({
    super.key,
    required this.progress,
  });

  final WorkoutProgressModel progress;

  static const Color accent = Color(0xFFFF4B2B);

  @override
  Widget build(BuildContext context) {
    final hasData = progress.sessionsThisWeek > 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1C1C1E),
              Color(0xFF101012),
            ],
          ),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progress Overview',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Your session activity & training stats',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),

            const SizedBox(height: 20),

            /// 🔥 Progress bar
            _ProgressCard(
              progress: progress.overallCompletion / 100,
              hasData: hasData,
            ),

            const SizedBox(height: 18),

            /// 🔥 Stats grid
            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Total Volume',
                    value: '${progress.totalVolume} kg',
                    subtitle: 'All sessions',
                    icon: Icons.scale_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Avg Session',
                    value: '${progress.avgSessionVolume} kg',
                    subtitle: 'Per session',
                    icon: Icons.trending_up_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'This Week',
                    value: '${progress.sessionsThisWeek}',
                    subtitle: 'Sessions',
                    icon: Icons.calendar_today_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Weekly Volume',
                    value: '${progress.weeklyVolume} kg',
                    subtitle: 'Avg ${progress.avgWeeklyVolume} kg',
                    icon: Icons.bar_chart_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// 🔥 Chart
            _ChartCard(trend: progress.volumeTrend),

            const SizedBox(height: 12),

            /// 🔥 Top exercise
            _WideStatCard(
              title: 'Top Volume Exercise',
              value: progress.topVolumeExercise.isEmpty
                  ? 'No data yet'
                  : progress.topVolumeExercise,
              subtitle: 'Based on session volume',
              icon: Icons.workspace_premium_rounded,
            ),

            const SizedBox(height: 8),

            /// 🔥 Top workout
            _WideStatCard(
              title: 'Top Workout',
              value: progress.topWorkout.isEmpty
                  ? 'No data yet'
                  : progress.topWorkout,
              subtitle: 'Based on sessions',
              icon: Icons.local_fire_department_rounded,
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Saved Workouts',
                    value: '${progress.savedWorkouts}',
                    subtitle: 'Plans created',
                    icon: Icons.folder_open_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    title: 'Exercises',
                    value: '${progress.exercisesInsidePlans}',
                    subtitle: 'Inside plans',
                    icon: Icons.sports_gymnastics_rounded,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({
    required this.progress,
    required this.hasData,
  });

  final double progress;
  final bool hasData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            hasData
                ? '${(progress * 100).toInt()}%'
                : 'No sessions yet',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: hasData ? progress : 0,
              minHeight: 8,
              backgroundColor: Colors.white12,
              valueColor:
                  const AlwaysStoppedAnimation(Color(0xFFFF4B2B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  const _ChartCard({required this.trend});

  final List<VolumeTrendModel> trend;

  @override
  Widget build(BuildContext context) {
    if (trend.isEmpty) {
      return Container(
        height: 170,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Center(
          child: Text(
            'No session data yet\nStart logging sessions to see the graph',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, height: 1.4),
          ),
        ),
      );
    }

    return Container(
      height: 230,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session Volume Trend',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Volume across completed workout sessions',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: 0,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (_) {
                    return FlLine(
                      color: Colors.white.withValues(alpha: .08),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 38,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value >= 1000
                              ? '${(value / 1000).toStringAsFixed(1)}k'
                              : value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 24,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= trend.length) {
                          return const SizedBox.shrink();
                        }

                        return Text(
                          trend[index].dateLabel,
                          style: const TextStyle(
                            color: Colors.white38,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: List.generate(trend.length, (i) {
                      return FlSpot(
                        i.toDouble(),
                        trend[i].volume.toDouble(),
                      );
                    }),
                    isCurved: true,
                    color: const Color(0xFFFF4B2B),
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: FlDotData(show: true),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFFFF4B2B).withValues(alpha: .12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: Colors.white.withValues(alpha: .04),
    borderRadius: BorderRadius.circular(18),
    border: Border.all(color: Colors.white.withValues(alpha: .08)),
  );
}
class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.white60, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(subtitle,
              style: const TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

class _WideStatCard extends StatelessWidget {
  const _WideStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: .04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style:
                      const TextStyle(color: Colors.white60, fontSize: 12)),
              const SizedBox(height: 4),
              Text(value,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
              Text(subtitle,
                  style:
                      const TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}