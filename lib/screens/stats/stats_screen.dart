import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/flavors_data.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/stat_card.dart';

final _statsPeriodProvider = StateProvider<StatPeriod>((ref) => StatPeriod.month);

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(activeUidProvider);
    final period = ref.watch(_statsPeriodProvider);
    final stats = ref.watch(periodStatsProvider((uid, period)));

    final periodLabel = switch (period) {
      StatPeriod.today => 'Today · ${DateFormat('MMM d').format(DateTime.now())}',
      StatPeriod.week => 'This Week',
      StatPeriod.month => DateFormat('MMMM yyyy').format(DateTime.now()),
      StatPeriod.allTime => 'All Time',
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('My Stats', style: Theme.of(context).textTheme.headlineLarge),
              Text(periodLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),

              // Period chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: StatPeriod.values.map((p) {
                    final isSelected = p == period;
                    final label = switch (p) {
                      StatPeriod.today => 'Today',
                      StatPeriod.week => 'This Week',
                      StatPeriod.month => 'This Month',
                      StatPeriod.allTime => 'All Time',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(label),
                        selected: isSelected,
                        onSelected: (_) => ref.read(_statsPeriodProvider.notifier).state = p,
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

              const SizedBox(height: 20),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  StatCard(
                    label: _countLabel(period),
                    value: '${stats.monthCount}',
                    icon: Icons.local_drink_outlined,
                    accentColor: AppColors.redbull,
                  ),
                  StatCard(
                    label: 'TOTAL CAFFEINE',
                    value: '${stats.monthCaffeine}mg',
                    sub: _periodSub(period),
                    icon: Icons.bolt,
                    accentColor: const Color(0xFFFFD700),
                  ),
                  StatCard(
                    label: 'CURRENT STREAK',
                    value: '${stats.streak}d',
                    sub: stats.streak > 0 ? 'keep it going' : 'drink something',
                    icon: Icons.local_fire_department_outlined,
                    accentColor: const Color(0xFFFF6B35),
                  ),
                  StatCard(
                    label: _avgLabel(period),
                    value: stats.dailyAvg.toStringAsFixed(1),
                    sub: 'cans per day',
                    icon: Icons.trending_up,
                    accentColor: AppColors.monster,
                  ),
                ],
              ),

              // Heatmap — hidden for today
              if (period != StatPeriod.today) ...[
                const SizedBox(height: 28),
                Text(
                  'ACTIVITY',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 12),
                _CalendarHeatmap(
                  dailyCounts: stats.dailyCounts,
                  days: _heatmapDays(period),
                ),
              ],

              const SizedBox(height: 28),
              Text(
                'BRAND SPLIT',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _BrandSplit(breakdown: stats.brandBreakdown),
              const SizedBox(height: 28),
              Text(
                'FAVORITE FLAVORS',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _TopFlavors(breakdown: stats.flavorBreakdown),
            ],
          ),
        ),
      ),
    );
  }

  String _countLabel(StatPeriod p) => switch (p) {
    StatPeriod.today => 'CANS TODAY',
    StatPeriod.week => 'CANS THIS WEEK',
    StatPeriod.month => 'CANS THIS MONTH',
    StatPeriod.allTime => 'TOTAL CANS',
  };

  String _avgLabel(StatPeriod p) => switch (p) {
    StatPeriod.today => 'TODAY\'S TOTAL',
    StatPeriod.week => 'WEEKLY AVG',
    StatPeriod.month => 'DAILY AVERAGE',
    StatPeriod.allTime => 'DAILY AVERAGE',
  };

  String? _periodSub(StatPeriod p) => switch (p) {
    StatPeriod.today => 'today',
    StatPeriod.week => 'this week',
    StatPeriod.month => 'this month',
    StatPeriod.allTime => 'all time',
  };

  int _heatmapDays(StatPeriod p) => switch (p) {
    StatPeriod.today => 1,
    StatPeriod.week => 7,
    StatPeriod.month => 30,
    StatPeriod.allTime => 90,
  };
}

class _CalendarHeatmap extends StatelessWidget {
  final Map<DateTime, int> dailyCounts;
  final int days;
  const _CalendarHeatmap({required this.dailyCounts, required this.days});

  @override
  Widget build(BuildContext context) {
    final now = jordanNow();
    final daysList = List.generate(days, (i) {
      final d = now.subtract(Duration(days: days - 1 - i));
      return DateTime(d.year, d.month, d.day);
    });

    final maxCount = dailyCounts.values.fold(0, (m, v) => v > m ? v : m);

    // For week view: show day labels
    final showDayLabels = days == 7;
    final cols = days == 7 ? 7 : 10;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          if (showDayLabels) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: daysList.map((d) => Text(
                DateFormat('E').format(d).substring(0, 2),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 10),
              )).toList(),
            ),
            const SizedBox(height: 6),
          ],
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 1,
            ),
            itemCount: daysList.length,
            itemBuilder: (ctx, i) {
              final count = dailyCounts[daysList[i]] ?? 0;
              final intensity = maxCount > 0 ? count / maxCount : 0.0;
              return Tooltip(
                message: '${DateFormat('MMM d').format(daysList[i])}: $count cans',
                child: Container(
                  decoration: BoxDecoration(
                    color: count == 0
                        ? AppColors.surface
                        : AppColors.redbull.withAlpha((intensity * 220).round()),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('MMM d').format(daysList.first),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
              Row(
                children: [
                  const Text('less', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                  const SizedBox(width: 6),
                  ...List.generate(5, (i) => Container(
                    width: 12,
                    height: 12,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: AppColors.redbull.withAlpha(((i + 1) / 5 * 220).round()),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  )),
                  const SizedBox(width: 6),
                  const Text('more', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
                ],
              ),
              Text(
                DateFormat('MMM d').format(daysList.last),
                style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandSplit extends StatelessWidget {
  final Map<String, int> breakdown;
  const _BrandSplit({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    final total = breakdown.values.fold(0, (s, v) => s + v);
    if (total == 0) return const SizedBox();
    final rb = breakdown['redbull'] ?? 0;
    final mon = breakdown['monster'] ?? 0;
    final rbPct = total > 0 ? rb / total : 0.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  Expanded(flex: (rbPct * 100).round(), child: Container(color: AppColors.redbull)),
                  Expanded(flex: ((1 - rbPct) * 100).round(), child: Container(color: AppColors.monster)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _BrandChip(label: 'Red Bull', count: rb, color: AppColors.redbull),
              const SizedBox(width: 12),
              _BrandChip(label: 'Monster', count: mon, color: AppColors.monster),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _BrandChip({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: $count', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

class _TopFlavors extends StatelessWidget {
  final Map<String, int> breakdown;
  const _TopFlavors({required this.breakdown});

  @override
  Widget build(BuildContext context) {
    if (breakdown.isEmpty) return const SizedBox();

    final sorted = breakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(5).toList();
    final max = top.first.value;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: top.map((e) {
          final flavor = flavorById(e.key);
          final pct = e.value / max;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(flavor?.name ?? e.key, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13)),
                    Text('${e.value}x', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: pct,
                    minHeight: 6,
                    backgroundColor: AppColors.surface,
                    valueColor: AlwaysStoppedAnimation(flavor?.color ?? AppColors.redbull),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
