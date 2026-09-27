import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../data/flavors_data.dart';
import '../../services/auth_service.dart';
import '../../services/firestore_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _uploadingPhoto = false;

  Future<void> _pickPhoto() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null) return;

    setState(() => _uploadingPhoto = true);
    try {
      await FirestoreService.uploadProfilePhoto(uid, File(picked.path));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _uploadingPhoto = false);
    }
  }

  Future<void> _editName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final profile = ref.read(currentUserProfileProvider).value;
    final controller = TextEditingController(text: profile?.displayName ?? '');

    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.cardBorder),
        ),
        title: const Text('Display name', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintStyle: TextStyle(color: AppColors.textMuted),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppColors.redbull),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save', style: TextStyle(color: AppColors.redbull)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty) {
      await FirestoreService.updateDisplayName(uid, result);
      ref.invalidate(currentUserProfileProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(activeUidProvider);
    final profile = ref.watch(currentUserProfileProvider).value;
    final stats = ref.watch(statsProvider(uid));
    final allLogs = ref.watch(userLogsProvider(uid)).value ?? [];
    final favFlavor = stats.favFlavorId != null ? flavorById(stats.favFlavorId!) : null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Profile', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 28),

              // ── Avatar + name ──────────────────────────────────────────────
              Row(
                children: [
                  _AvatarPicker(
                    photoURL: profile?.photoURL,
                    name: profile?.displayName ?? '',
                    uploading: _uploadingPhoto,
                    onTap: _pickPhoto,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: _editName,
                          child: Row(
                            children: [
                              Flexible(
                                child: Text(
                                  profile?.displayName ?? '',
                                  style: GoogleFonts.rajdhani(
                                    color: AppColors.textPrimary,
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.5,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(Icons.edit_outlined, size: 16, color: AppColors.textMuted),
                            ],
                          ),
                        ),
                        if (profile != null)
                          Text(
                            'since ${DateFormat('MMM yyyy').format(profile.joinedAt)}',
                            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                          ),
                        const SizedBox(height: 8),
                        _CaffeineBadge(mg: stats.monthCaffeine),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // ── All-time stats row ─────────────────────────────────────────
              Row(
                children: [
                  Expanded(child: _StatBox(value: '${allLogs.length}', label: 'total cans')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox(value: '${allLogs.fold(0, (acc, l) => acc + l.caffeineMg)}mg', label: 'total caffeine')),
                  const SizedBox(width: 10),
                  Expanded(child: _StatBox(value: '${stats.streak}d', label: 'streak', accent: const Color(0xFFFF6B35))),
                ],
              ),

              // ── Fav drink ──────────────────────────────────────────────────
              if (favFlavor != null) ...[
                const SizedBox(height: 24),
                Text('FAVOURITE', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: favFlavor.color.withAlpha(20),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: favFlavor.color.withAlpha(80)),
                    boxShadow: neonGlow(favFlavor.color, radius: 10, intensity: 0.15),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: favFlavor.color,
                          shape: BoxShape.circle,
                          boxShadow: neonGlow(favFlavor.color, radius: 6, intensity: 0.8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${favFlavor.brandName} ${favFlavor.name}',
                              style: TextStyle(
                                color: favFlavor.color,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'your most logged drink',
                              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${stats.flavorBreakdown[favFlavor.id]}x',
                        style: TextStyle(
                          color: favFlavor.color,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'Rajdhani',
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 32),
              const Divider(color: AppColors.divider),
              const SizedBox(height: 24),

              // ── Settings ───────────────────────────────────────────────────
              Text('SETTINGS', style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 12),
              _SettingsTile(
                icon: Icons.logout,
                label: 'Sign out',
                sub: FirebaseAuth.instance.currentUser?.email ?? '',
                destructive: true,
                onTap: AuthService.signOut,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────────

class _AvatarPicker extends StatelessWidget {
  final String? photoURL;
  final String name;
  final bool uploading;
  final VoidCallback onTap;

  const _AvatarPicker({
    required this.photoURL,
    required this.name,
    required this.uploading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.redbull.withAlpha(120), width: 2),
              boxShadow: neonGlow(AppColors.redbull, radius: 14, intensity: 0.3),
            ),
            child: ClipOval(
              child: uploading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.redbull, strokeWidth: 2))
                  : photoURL != null
                      ? Image.network(photoURL!, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _Initial(name: name, size: 80))
                      : _Initial(name: name, size: 80),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.redbull,
                shape: BoxShape.circle,
                boxShadow: neonGlow(AppColors.redbull, radius: 6, intensity: 0.5),
              ),
              child: const Icon(Icons.camera_alt, size: 13, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final double size;
  const _Initial({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      color: AppColors.redbull.withAlpha(20),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
            color: AppColors.redbull,
            fontSize: size * 0.38,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final Color? accent;
  const _StatBox({required this.value, required this.label, this.accent});

  @override
  Widget build(BuildContext context) {
    final color = accent ?? AppColors.redbull;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: GoogleFonts.rajdhani(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: color.withAlpha(120), blurRadius: 8)],
              ),
            ),
          ),
          Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CaffeineBadge extends StatelessWidget {
  final int mg;
  const _CaffeineBadge({required this.mg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withAlpha(60)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bolt, size: 12, color: AppColors.gold, shadows: [Shadow(color: AppColors.gold.withAlpha(180), blurRadius: 8)]),
          const SizedBox(width: 4),
          Text('${mg}mg this month', style: TextStyle(color: AppColors.gold, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final bool destructive;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = destructive ? AppColors.redbull : AppColors.textSecondary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: destructive ? AppColors.redbull.withAlpha(40) : AppColors.cardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: TextStyle(color: color, fontSize: 15, fontWeight: FontWeight.w600)),
                  if (sub.isNotEmpty) Text(sub, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}
