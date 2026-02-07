import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:potion_focus/core/theme/app_colors.dart';
import 'package:potion_focus/services/statistics_service.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overview = ref.watch(overviewStatsProvider);
    final weekly = ref.watch(weeklyMinutesProvider);
    final monthly = ref.watch(monthlyMinutesProvider);
    final topTags = ref.watch(topTagsProvider);
    final rarityDist = ref.watch(rarityDistributionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Focus Journey',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Overview cards
          overview.when(
            data: (stats) => Row(
              children: [
                Expanded(child: _OverviewCard(
                  icon: Icons.schedule,
                  value: '${stats.totalHours.toStringAsFixed(1)}h',
                  label: 'Total Focus',
                )),
                const SizedBox(width: 12),
                Expanded(child: _OverviewCard(
                  icon: Icons.local_fire_department,
                  value: '${stats.currentStreak}',
                  label: 'Day Streak',
                )),
                const SizedBox(width: 12),
                Expanded(child: _OverviewCard(
                  icon: Icons.science,
                  value: '${stats.totalPotions}',
                  label: 'Potions',
                )),
              ],
            ),
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Weekly trend
          Text('Last 7 Days', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          weekly.when(
            data: (data) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: data.map((e) => e.toDouble()).toList(),
                      labels: _getWeekdayLabels(),
                      barColor: AppColors.primaryLight,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(height: 180),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Monthly trend
          Text('Last 4 Weeks', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          monthly.when(
            data: (data) => Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  height: 160,
                  child: CustomPaint(
                    painter: _BarChartPainter(
                      values: data.map((e) => e.toDouble()).toList(),
                      labels: ['Wk 4', 'Wk 3', 'Wk 2', 'This Wk'],
                      barColor: AppColors.secondaryLight,
                    ),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
            loading: () => const SizedBox(height: 180),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Top tags
          Text('Most Focused Tags', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          topTags.when(
            data: (tags) {
              if (tags.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Complete sessions with tags to see stats',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final maxMinutes = tags.map((t) => t.minutes).reduce(math.max);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: tags.map((tag) {
                      final fraction = maxMinutes > 0 ? tag.minutes / maxMinutes : 0.0;
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: Text(
                                '#${tag.tag}',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.zero,
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  minHeight: 16,
                                  backgroundColor: AppColors.primaryLight.withValues(alpha: 0.1),
                                  valueColor: AlwaysStoppedAnimation(
                                    AppColors.primaryLight.withValues(alpha: 0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              '${tag.minutes}m',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 24),

          // Rarity distribution
          Text('Potion Rarity', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          rarityDist.when(
            data: (dist) {
              if (dist.isEmpty) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Brew potions to see your collection stats',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              const order = ['common', 'uncommon', 'rare', 'epic', 'legendary', 'muddy'];
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: order.where((r) => dist.containsKey(r)).map((rarity) {
                      final count = dist[rarity]!;
                      final color = AppColors.getRarityColor(rarity);
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.zero,
                          border: Border.all(color: color.withValues(alpha: 0.4)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: color,
                              ),
                            ),
                            Text(
                              rarity[0].toUpperCase() + rarity.substring(1),
                              style: TextStyle(fontSize: 11, color: color),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            },
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  List<String> _getWeekdayLabels() {
    final now = DateTime.now();
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return List.generate(7, (i) {
      final d = now.subtract(Duration(days: 6 - i));
      return days[d.weekday - 1];
    });
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _OverviewCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primaryLight, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Pixel-art vertical bar chart painter — sharp rectangles, no rounding.
class _BarChartPainter extends CustomPainter {
  final List<double> values;
  final List<String> labels;
  final Color barColor;

  _BarChartPainter({
    required this.values,
    required this.labels,
    required this.barColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final maxVal = values.reduce(math.max);
    final effectiveMax = maxVal > 0 ? maxVal : 1.0;
    final barCount = values.length;
    final barWidth = size.width / (barCount * 2);
    const bottomPadding = 24.0;
    final chartHeight = size.height - bottomPadding;

    final barPaint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill
      ..isAntiAlias = false;

    final textStyle = TextStyle(
      color: barColor.withValues(alpha: 0.8),
      fontSize: 9,
    );

    for (int i = 0; i < barCount; i++) {
      final x = (i * 2 + 0.5) * barWidth;
      final barHeight = (values[i] / effectiveMax) * chartHeight * 0.85;

      // Sharp pixel bar (no border radius)
      barPaint.color = barColor.withValues(alpha: 0.7);
      canvas.drawRect(
        Rect.fromLTWH(x, chartHeight - barHeight, barWidth, barHeight),
        barPaint,
      );

      // Pixel highlight on left edge of bar
      barPaint.color = Colors.white.withValues(alpha: 0.15);
      canvas.drawRect(
        Rect.fromLTWH(x, chartHeight - barHeight, 2, barHeight),
        barPaint,
      );

      // Value label on top
      if (values[i] > 0) {
        final valuePainter = TextPainter(
          text: TextSpan(
            text: '${values[i].round()}',
            style: textStyle.copyWith(fontWeight: FontWeight.bold),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        valuePainter.paint(
          canvas,
          Offset(x + barWidth / 2 - valuePainter.width / 2, chartHeight - barHeight - 14),
        );
      }

      // Label below
      if (i < labels.length) {
        final labelPainter = TextPainter(
          text: TextSpan(text: labels[i], style: textStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        labelPainter.paint(
          canvas,
          Offset(x + barWidth / 2 - labelPainter.width / 2, chartHeight + 4),
        );
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
