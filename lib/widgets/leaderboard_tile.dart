import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/profile/user_profile_screen.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';

class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const LeaderboardTile({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final isFirst = entry.rank == 1;
    final rankColor = switch (entry.rank) {
      1 => AppColors.gold,
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => AppColors.textMuted,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.of(context, rootNavigator: false).push(
            MaterialPageRoute(builder: (_) => UserProfileScreen(user: entry.user)),
          ),
          borderRadius: BorderRadius.circular(16),
          splashColor: AppColors.redbull.withAlpha(30),
          highlightColor: AppColors.redbull.withAlpha(15),
          child: Container(
          // margin removed — handled by Padding above
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: entry.isCurrentUser ? AppColors.redbull.withAlpha(10) : AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entry.isCurrentUser ? AppColors.redbull.withAlpha(80) : AppColors.cardBorder,
          width: entry.isCurrentUser ? 1.5 : 1,
        ),
        boxShadow: entry.isCurrentUser
            ? neonGlow(AppColors.redbull, radius: 10, intensity: 0.15)
            : null,
      ),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              '#${entry.rank}',
              style: GoogleFonts.rajdhani(
                color: rankColor,
                fontSize: isFirst ? 22 : 18,
                fontWeight: FontWeight.w800,
                shadows: isFirst
                    ? [Shadow(color: rankColor.withAlpha(180), blurRadius: 12)]
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _Avatar(name: entry.user.displayName, photoURL: entry.user.photoURL),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.user.displayName,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Text(
            entry.label,
            style: TextStyle(
              color: isFirst ? rankColor : AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
              fontFamily: 'Rajdhani',
              shadows: isFirst
                  ? [Shadow(color: rankColor.withAlpha(160), blurRadius: 10)]
                  : null,
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

class _Avatar extends StatelessWidget {
  final String name;
  final String? photoURL;
  const _Avatar({required this.name, this.photoURL});

  @override
  Widget build(BuildContext context) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.redbull.withAlpha(80), width: 1.5),
        boxShadow: neonGlow(AppColors.redbull, radius: 6, intensity: 0.2),
      ),
      child: ClipOval(
        child: photoURL != null
            ? Image.network(photoURL!, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _Initials(initial: initial))
            : _Initials(initial: initial),
      ),
    );
  }
}

class _Initials extends StatelessWidget {
  final String initial;
  const _Initials({required this.initial});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.redbull.withAlpha(25),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(
            color: AppColors.redbull,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
