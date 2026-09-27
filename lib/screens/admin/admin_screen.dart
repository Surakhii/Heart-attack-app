import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/firestore_service.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';

class AdminScreen extends ConsumerWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final users = ref.watch(allUsersProvider).value ?? [];
    final currentUid = ref.watch(activeUidProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Admin', style: Theme.of(context).textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text('${users.length} users', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 24),
              Expanded(
                child: ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (ctx, i) {
                    final user = users[i];
                    final isMe = user.uid == currentUid;
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.redbull.withAlpha(20),
                            backgroundImage: user.photoURL != null
                                ? NetworkImage(user.photoURL!) as ImageProvider
                                : null,
                            child: user.photoURL == null
                                ? Text(
                                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : '?',
                                    style: const TextStyle(color: AppColors.redbull, fontWeight: FontWeight.w700),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      user.displayName,
                                      style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w600),
                                    ),
                                    if (isMe) ...[
                                      const SizedBox(width: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.redbull.withAlpha(20),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: const Text('you', style: TextStyle(color: AppColors.redbull, fontSize: 10, fontWeight: FontWeight.w700)),
                                      ),
                                    ],
                                  ],
                                ),
                                Text(user.uid.substring(0, 12) + '...', style: const TextStyle(color: AppColors.textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          if (!isMe)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: AppColors.redbull),
                              onPressed: () => _confirmDelete(context, ref, user.displayName, user.uid),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String name, String uid) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.redbull),
        ),
        title: const Text('Remove user?', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'This deletes $name\'s account and all their logs. They can rejoin with the invite code.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await FirestoreService.deleteUserData(uid);
              ref.invalidate(allUsersProvider);
            },
            child: const Text('Remove', style: TextStyle(color: AppColors.redbull, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
