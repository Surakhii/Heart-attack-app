import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../data/flavors_data.dart';
import '../../models/user_model.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class UserProfileScreen extends ConsumerWidget {
  final UserModel user;
  const UserProfileScreen({super.key, required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(statsProvider(user.uid));
    final allLogs = ref.watch(userLogsProvider(user.uid)).value ?? [];
    final recentLogs = allLogs.take(5).toList();
    final favFlavor = stats.favFlavorId != null ? flavorById(stats.favFlavorId!) : null;
    final isMe = FirebaseAuth.instance.currentUser?.uid == user.uid;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: const Alignment(0.8, -0.8),
            radius: 0.65,
            colors: [AppColors.redbull.withAlpha(15), AppColors.background],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // ── Header ──────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textSecondary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isMe ? 'Your profile' : '${user.displayName}\'s profile',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Avatar
                      Container(
                        width: 96,
                        height: 96,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.redbull.withAlpha(140), width: 2.5),
                          boxShadow: neonGlow(AppColors.redbull, radius: 20, intensity: 0.35),
                        ),
                        child: ClipOval(
                          child: user.photoURL != null
                              ? Image.network(user.photoURL!, fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _Initial(name: user.displayName))
                              : _Initial(name: user.displayName),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text(
                        user.displayName,
                        style: GoogleFonts.rajdhani(
                          color: AppColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Text(
                        'wired since ${DateFormat('MMM yyyy').format(user.joinedAt)}',
                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 28),

                      // Stats row
                      Row(
                        children: [
                          _StatPill(value: '${stats.monthCount}', label: 'cans\nthis month', accent: AppColors.redbull),
                          const SizedBox(width: 10),
                          _StatPill(value: '${stats.monthCaffeine}mg', label: 'caffeine\nthis month', accent: AppColors.gold),
                          const SizedBox(width: 10),
                          _StatPill(value: '${stats.streak}d', label: 'current\nstreak', accent: const Color(0xFFFF6B35)),
                        ],
                      ),

                      // Fav drink
                      if (favFlavor != null) ...[
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: favFlavor.color.withAlpha(15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: favFlavor.color.withAlpha(80)),
                            boxShadow: neonGlow(favFlavor.color, radius: 12, intensity: 0.15),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 10, height: 10,
                                decoration: BoxDecoration(
                                  color: favFlavor.color, shape: BoxShape.circle,
                                  boxShadow: neonGlow(favFlavor.color, radius: 6, intensity: 0.8),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('favourite drink',
                                        style: const TextStyle(color: AppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                                    Text(
                                      '${favFlavor.brandName} ${favFlavor.name}',
                                      style: TextStyle(color: favFlavor.color, fontSize: 16, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '${stats.flavorBreakdown[favFlavor.id]}×',
                                style: GoogleFonts.rajdhani(
                                  color: favFlavor.color, fontSize: 24, fontWeight: FontWeight.w800,
                                  shadows: [Shadow(color: favFlavor.color.withAlpha(140), blurRadius: 10)],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 28),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('RECENT DRINKS', style: Theme.of(context).textTheme.labelLarge),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── Recent logs ──────────────────────────────────────────────────
              if (recentLogs.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('no drinks logged yet', style: TextStyle(color: AppColors.textMuted)),
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      final log = recentLogs[i];
                      final isRB = log.brandId == 'redbull';
                      final accent = isRB ? AppColors.redbull : AppColors.monster;
                      final flavor = flavorById(log.flavorId);
                      return Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.cardBorder),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 4, height: 36,
                                decoration: BoxDecoration(
                                  color: flavor?.color ?? accent,
                                  borderRadius: BorderRadius.circular(2),
                                  boxShadow: neonGlow(flavor?.color ?? accent, radius: 6, intensity: 0.5),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(log.flavorName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
                                    Text('${log.sizeML}ml', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
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
                                    ),
                                    child: Text('${log.caffeineMg}mg',
                                        style: TextStyle(color: accent, fontSize: 12, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(DateFormat('MMM d').format(log.timestamp),
                                      style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: recentLogs.length,
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color accent;
  const _StatPill({required this.value, required this.label, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        decoration: BoxDecoration(
          color: accent.withAlpha(12),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: accent.withAlpha(50)),
          boxShadow: neonGlow(accent, radius: 8, intensity: 0.1),
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                style: GoogleFonts.rajdhani(
                  color: accent, fontSize: 24, fontWeight: FontWeight.w800,
                  shadows: [Shadow(color: accent.withAlpha(150), blurRadius: 12)],
                ),
              ),
            ),
            Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  const _Initial({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.redbull.withAlpha(20),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(color: AppColors.redbull, fontSize: 36, fontWeight: FontWeight.w800),
        ),
      ),
    );
  }
}
