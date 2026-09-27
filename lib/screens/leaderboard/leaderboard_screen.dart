import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/leaderboard_tile.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  LeaderboardMetric _metric = LeaderboardMetric.count;
  StatPeriod _period = StatPeriod.month;

  // Streak doesn't apply to today/week
  List<LeaderboardMetric> _availableMetrics() {
    if (_period == StatPeriod.today || _period == StatPeriod.week) {
      return [LeaderboardMetric.count, LeaderboardMetric.caffeine, LeaderboardMetric.dailyAvg];
    }
    return LeaderboardMetric.values;
  }

  @override
  Widget build(BuildContext context) {
    // Reset to count if current metric is unavailable for this period
    final available = _availableMetrics();
    if (!available.contains(_metric)) _metric = LeaderboardMetric.count;

    final entries = ref.watch(leaderboardProvider((_metric, _period)));

    final periodLabel = switch (_period) {
      StatPeriod.today => 'Today',
      StatPeriod.week => 'This Week',
      StatPeriod.month => 'This Month',
      StatPeriod.allTime => 'All Time',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AuroraBackground(
        accent1: AppColors.purple,
        accent2: AppColors.redbull,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Leaderboard', style: Theme.of(context).textTheme.headlineLarge),
                Text(periodLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                const SizedBox(height: 16),

                // Period chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: StatPeriod.values.map((p) {
                      final isSelected = p == _period;
                      final label = switch (p) {
                        StatPeriod.today => 'Today',
                        StatPeriod.week => 'Week',
                        StatPeriod.month => 'Month',
                        StatPeriod.allTime => 'All Time',
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _period = p),
                          selectedColor: AppColors.purple.withAlpha(40),
                          checkmarkColor: AppColors.purple,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.purple : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.purple.withAlpha(80) : AppColors.cardBorder,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 10),

                // Metric chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: available.map((m) {
                      final isSelected = m == _metric;
                      final label = switch (m) {
                        LeaderboardMetric.count => 'Cans',
                        LeaderboardMetric.caffeine => 'Caffeine',
                        LeaderboardMetric.streak => 'Streak',
                        LeaderboardMetric.dailyAvg => 'Daily Avg',
                      };
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (_) => setState(() => _metric = m),
                          selectedColor: AppColors.redbull.withAlpha(30),
                          checkmarkColor: AppColors.redbull,
                          labelStyle: TextStyle(
                            color: isSelected ? AppColors.redbull : AppColors.textSecondary,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          ),
                          side: BorderSide(
                            color: isSelected ? AppColors.redbull.withAlpha(80) : AppColors.cardBorder,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (ctx, i) => LeaderboardTile(entry: entries[i]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
