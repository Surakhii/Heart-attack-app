import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/flavors_data.dart';
import '../../models/flavor.dart';
import '../../models/log_entry.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../sheets/flavor_sheet.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(activeUidProvider);
    final profile = ref.watch(currentUserProfileProvider).value;
    final stats = ref.watch(statsProvider(uid));
    final recentLogs = ref.watch(userLogsProvider(uid)).value?.take(5).toList() ?? [];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: AuroraBackground(
        accent1: AppColors.redbull,
        accent2: AppColors.purple,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting
                      Text(
                        profile?.displayName ?? '',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              "What's your\npoison today?",
                              style: GoogleFonts.rajdhani(
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                color: AppColors.textPrimary,
                                height: 1.0,
                                letterSpacing: -0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Big stat
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [AppColors.redbull, const Color(0xFFFF6B00)],
                                ).createShader(bounds),
                                child: Text(
                                  '${stats.monthCount}',
                                  style: GoogleFonts.rajdhani(
                                    fontSize: 60,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1,
                                    shadows: [
                                      Shadow(color: AppColors.redbull.withAlpha(180), blurRadius: 30),
                                      Shadow(color: AppColors.redbull.withAlpha(80), blurRadius: 60),
                                    ],
                                  ),
                                ),
                              ),
                              Text(
                                'cans · ${DateFormat('MMM').format(DateTime.now())}',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Caffeine strip
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withAlpha(15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.gold.withAlpha(40)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.bolt, size: 14, color: AppColors.gold,
                                shadows: [Shadow(color: AppColors.gold.withAlpha(200), blurRadius: 8)]),
                            const SizedBox(width: 4),
                            Text(
                              '${stats.monthCaffeine}mg caffeine this month',
                              style: TextStyle(
                                color: AppColors.gold,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                shadows: [Shadow(color: AppColors.gold.withAlpha(120), blurRadius: 6)],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Brand buttons
                      Row(
                        children: [
                          Expanded(
                            child: _BrandButton(
                              label: 'Red Bull',
                              sub: '${recentLogs.where((l) => l.brandId == 'redbull').length} today',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF3D0010), Color(0xFF1A0008)],
                              ),
                              glow: AppColors.redbull,
                              onTap: () => showFlavorSheet(context, Brand.redbull),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _BrandButton(
                              label: 'Monster',
                              sub: '${recentLogs.where((l) => l.brandId == 'monster').length} today',
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF003D18), Color(0xFF001A0A)],
                              ),
                              glow: AppColors.monster,
                              onTap: () => showFlavorSheet(context, Brand.monster),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Streak strip
                      if (stats.streak > 0)
                        Container(
                          margin: const EdgeInsets.only(bottom: 20),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: glassCard(
                            borderColor: const Color(0xFFFF6B35).withAlpha(80),
                            glow: neonGlow(const Color(0xFFFF6B35), radius: 8, intensity: 0.2),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department,
                                color: const Color(0xFFFF6B35),
                                shadows: [Shadow(color: const Color(0xFFFF6B35).withAlpha(200), blurRadius: 10)],
                              ),
                              const SizedBox(width: 10),
                              Text(
                                '${stats.streak} day streak',
                                style: const TextStyle(
                                  color: Color(0xFFFF6B35),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const Spacer(),
                              Text('keep it going', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                            ],
                          ),
                        ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('RECENT', style: Theme.of(context).textTheme.labelLarge),
                          Text(
                            DateFormat('MMMM d').format(DateTime.now()),
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              if (recentLogs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: Text(
                        'no drinks logged yet.\nhit a button above.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                      ),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      child: _LogTile(log: recentLogs[i]),
                    ),
                    childCount: recentLogs.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Brand Button ──────────────────────────────────────────────────────────────

class _BrandButton extends StatefulWidget {
  final String label;
  final String sub;
  final LinearGradient gradient;
  final Color glow;
  final VoidCallback onTap;

  const _BrandButton({
    required this.label,
    required this.sub,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  @override
  State<_BrandButton> createState() => _BrandButtonState();
}

class _BrandButtonState extends State<_BrandButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) { setState(() => _pressed = false); widget.onTap(); },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        height: 130,
        decoration: BoxDecoration(
          gradient: widget.gradient,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: widget.glow.withAlpha(_pressed ? 200 : 100),
            width: _pressed ? 2 : 1.5,
          ),
          boxShadow: neonGlow(widget.glow, radius: _pressed ? 28 : 14, intensity: _pressed ? 0.5 : 0.25),
        ),
        child: Stack(
          children: [
            // Background glow circle
            Positioned(
              right: -20, top: -20,
              child: Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [widget.glow.withAlpha(40), Colors.transparent],
                  ),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(
                    Icons.add_circle_rounded,
                    color: widget.glow,
                    size: 30,
                    shadows: [Shadow(color: widget.glow.withAlpha(200), blurRadius: 12)],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.glow,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          shadows: [Shadow(color: widget.glow.withAlpha(160), blurRadius: 10)],
                        ),
                      ),
                      Text(
                        widget.sub,
                        style: TextStyle(color: widget.glow.withAlpha(140), fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Log Tile ──────────────────────────────────────────────────────────────────

class _LogTile extends StatelessWidget {
  final LogEntry log;
  const _LogTile({required this.log});

  @override
  Widget build(BuildContext context) {
    final isRB = log.brandId == 'redbull';
    final accent = isRB ? AppColors.redbull : AppColors.monster;
    final flavor = flavorById(log.flavorId);
    final tileColor = flavor?.color ?? accent;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: glassCard(
        borderColor: tileColor.withAlpha(50),
      ),
      child: Row(
        children: [
          Container(
            width: 4, height: 40,
            decoration: BoxDecoration(
              color: tileColor,
              borderRadius: BorderRadius.circular(2),
              boxShadow: neonGlow(tileColor, radius: 6, intensity: 0.6),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(log.flavorName,
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                Text('${log.sizeML}ml',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withAlpha(20),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: accent.withAlpha(40)),
                ),
                child: Text('${log.caffeineMg}mg',
                    style: TextStyle(
                      color: accent, fontSize: 12, fontWeight: FontWeight.w700,
                      shadows: [Shadow(color: accent.withAlpha(120), blurRadius: 6)],
                    )),
              ),
              const SizedBox(height: 4),
              Text(_timeAgo(log.timestamp),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.isNegative || diff.inMinutes < 2) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return DateFormat('MMM d').format(dt);
  }
}
