import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/log_entry.dart';
import '../models/user_model.dart';
import '../data/mock_data.dart';
import '../services/firestore_service.dart';

// ── Jordan time (UTC+3, no DST) ───────────────────────────────────────────────

DateTime jordanNow() =>
    DateTime.now().toUtc().add(const Duration(hours: 3));

DateTime _toJordan(DateTime utc) =>
    utc.toUtc().add(const Duration(hours: 3));

// ── Period ────────────────────────────────────────────────────────────────────

enum StatPeriod { today, week, month, allTime }

// ── Preview mode (skip Firebase auth for UI review) ──────────────────────────

final previewModeProvider = StateProvider<bool>((ref) => false);

// ── Auth ──────────────────────────────────────────────────────────────────────

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

// ── Active UID — Firebase uid or mock uid in preview ──────────────────────────

final activeUidProvider = Provider<String>((ref) {
  if (ref.watch(previewModeProvider)) return 'uid_surakhii';
  return FirebaseAuth.instance.currentUser?.uid ?? '';
});

// ── Admin check ───────────────────────────────────────────────────────────────

final isAdminProvider = Provider<bool>((ref) {
  if (ref.watch(previewModeProvider)) return false;
  final user = ref.watch(authStateProvider).value;
  return user?.email == 'ayhamsarkhi@gmail.com';
});

// ── User doc exists (invalidatable — used by invite flow) ─────────────────────

final userExistsProvider = FutureProvider<bool>((ref) async {
  if (ref.watch(previewModeProvider)) return true;
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return false;
  return FirestoreService.userDocExists(auth.uid);
});

// ── Current user profile (real-time stream) ───────────────────────────────────

final currentUserProfileProvider = StreamProvider<UserModel?>((ref) {
  if (ref.watch(previewModeProvider)) return Stream.value(mockUsers[0]);
  final auth = ref.watch(authStateProvider).value;
  if (auth == null) return Stream.value(null);
  return FirestoreService.currentUserStream(auth.uid);
});

// ── All users (for leaderboard) ───────────────────────────────────────────────

final allUsersProvider = StreamProvider<List<UserModel>>((ref) {
  if (ref.watch(previewModeProvider)) return Stream.value(mockUsers);
  return FirestoreService.allUsersStream();
});

// ── Logs per user ─────────────────────────────────────────────────────────────

final userLogsProvider = StreamProvider.family<List<LogEntry>, String>((ref, uid) {
  if (ref.watch(previewModeProvider)) {
    return Stream.value(mockLogs.where((l) => l.uid == uid).toList());
  }
  return FirestoreService.userLogsStream(uid);
});

final userMonthLogsProvider = Provider.family<List<LogEntry>, String>((ref, uid) {
  final now = jordanNow();
  return ref.watch(userLogsProvider(uid)).value?.where((l) {
    final lj = _toJordan(l.timestamp);
    return lj.year == now.year && lj.month == now.month;
  }).toList() ?? [];
});

// ── Stats ─────────────────────────────────────────────────────────────────────

class UserStats {
  final int monthCount;
  final int monthCaffeine;
  final int streak;
  final double dailyAvg;
  final Map<String, int> brandBreakdown;
  final Map<String, int> flavorBreakdown;
  final Map<DateTime, int> dailyCounts;
  final String? favFlavorId;

  const UserStats({
    required this.monthCount,
    required this.monthCaffeine,
    required this.streak,
    required this.dailyAvg,
    required this.brandBreakdown,
    required this.flavorBreakdown,
    required this.dailyCounts,
    this.favFlavorId,
  });

  static const empty = UserStats(
    monthCount: 0,
    monthCaffeine: 0,
    streak: 0,
    dailyAvg: 0,
    brandBreakdown: {},
    flavorBreakdown: {},
    dailyCounts: {},
  );
}

// statsProvider — always all-time / month (used by profile screens)
final statsProvider = Provider.family<UserStats, String>((ref, uid) {
  return ref.watch(periodStatsProvider((uid, StatPeriod.month)));
});

// periodStatsProvider — filtered by period
final periodStatsProvider = Provider.family<UserStats, (String, StatPeriod)>((ref, args) {
  final (uid, period) = args;
  final allLogs = ref.watch(userLogsProvider(uid)).value ?? [];
  final now = jordanNow();

  // Filter logs to period
  List<LogEntry> filtered;
  switch (period) {
    case StatPeriod.today:
      final todayStart = DateTime(now.year, now.month, now.day);
      filtered = allLogs.where((l) {
        final lj = _toJordan(l.timestamp);
        final lDay = DateTime(lj.year, lj.month, lj.day);
        return !lDay.isBefore(todayStart);
      }).toList();
    case StatPeriod.week:
      final daysBack = now.weekday - 1; // Monday = 0
      final weekStart = now.subtract(Duration(days: daysBack));
      final weekStartDay = DateTime(weekStart.year, weekStart.month, weekStart.day);
      filtered = allLogs.where((l) {
        final lj = _toJordan(l.timestamp);
        final lDay = DateTime(lj.year, lj.month, lj.day);
        return !lDay.isBefore(weekStartDay);
      }).toList();
    case StatPeriod.month:
      filtered = allLogs.where((l) {
        final lj = _toJordan(l.timestamp);
        return lj.year == now.year && lj.month == now.month;
      }).toList();
    case StatPeriod.allTime:
      filtered = allLogs;
  }

  final count = filtered.length;
  final caffeine = filtered.fold(0, (acc, l) => acc + l.caffeineMg);

  final double dailyAvg;
  switch (period) {
    case StatPeriod.today:
      dailyAvg = count.toDouble();
    case StatPeriod.week:
      dailyAvg = count / 7;
    case StatPeriod.month:
      dailyAvg = count / now.day.clamp(1, 31);
    case StatPeriod.allTime:
      if (allLogs.isEmpty) {
        dailyAvg = 0;
      } else {
        final oldest = _toJordan(allLogs.last.timestamp);
        final days = now.difference(oldest).inDays + 1;
        dailyAvg = count / days.clamp(1, 9999);
      }
  }

  // Streak is always computed from all logs regardless of period
  final logDays = allLogs.map((l) {
    final lj = _toJordan(l.timestamp);
    return DateTime(lj.year, lj.month, lj.day);
  }).toSet();

  int streak = 0;
  var day = DateTime(now.year, now.month, now.day);
  if (!logDays.contains(day)) day = day.subtract(const Duration(days: 1));
  while (logDays.contains(day)) {
    streak++;
    day = day.subtract(const Duration(days: 1));
  }

  final brandBreakdown = <String, int>{};
  final flavorBreakdown = <String, int>{};
  final dailyCounts = <DateTime, int>{};

  for (final log in filtered) {
    brandBreakdown[log.brandId] = (brandBreakdown[log.brandId] ?? 0) + 1;
    flavorBreakdown[log.flavorId] = (flavorBreakdown[log.flavorId] ?? 0) + 1;
    final lj = _toJordan(log.timestamp);
    final dk = DateTime(lj.year, lj.month, lj.day);
    dailyCounts[dk] = (dailyCounts[dk] ?? 0) + 1;
  }

  // Fav flavor from all-time logs
  final allFlavorBreakdown = <String, int>{};
  for (final log in allLogs) {
    allFlavorBreakdown[log.flavorId] = (allFlavorBreakdown[log.flavorId] ?? 0) + 1;
  }
  final favFlavorId = allFlavorBreakdown.isEmpty
      ? null
      : (allFlavorBreakdown.entries.toList()..sort((a, b) => b.value.compareTo(a.value))).first.key;

  return UserStats(
    monthCount: count,
    monthCaffeine: caffeine,
    streak: streak,
    dailyAvg: dailyAvg,
    brandBreakdown: brandBreakdown,
    flavorBreakdown: flavorBreakdown,
    dailyCounts: dailyCounts,
    favFlavorId: favFlavorId,
  );
});

// ── Add log ───────────────────────────────────────────────────────────────────

Future<void> addLog(LogEntry entry) => FirestoreService.addLog(entry);

// ── Leaderboard ───────────────────────────────────────────────────────────────

enum LeaderboardMetric { count, caffeine, streak, dailyAvg }

class LeaderboardEntry {
  final UserModel user;
  final int rank;
  final num value;
  final String label;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.user,
    required this.rank,
    required this.value,
    required this.label,
    required this.isCurrentUser,
  });
}

final leaderboardProvider = Provider.family<List<LeaderboardEntry>, (LeaderboardMetric, StatPeriod)>(
  (ref, args) {
    final (metric, period) = args;
    final users = ref.watch(allUsersProvider).value ?? [];
    final currentUid = ref.watch(activeUidProvider);

    final entries = users.map((user) {
      final stats = ref.watch(periodStatsProvider((user.uid, period)));
      num value;
      String label;
      switch (metric) {
        case LeaderboardMetric.count:
          value = stats.monthCount;
          label = '${stats.monthCount} cans';
        case LeaderboardMetric.caffeine:
          value = stats.monthCaffeine;
          label = '${stats.monthCaffeine}mg';
        case LeaderboardMetric.streak:
          value = stats.streak;
          label = '${stats.streak} days';
        case LeaderboardMetric.dailyAvg:
          value = stats.dailyAvg;
          label = '${stats.dailyAvg.toStringAsFixed(1)}/day';
      }
      return LeaderboardEntry(
        user: user,
        rank: 0,
        value: value,
        label: label,
        isCurrentUser: user.uid == currentUid,
      );
    }).toList();

    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries.asMap().entries.map((e) => LeaderboardEntry(
      user: e.value.user,
      rank: e.key + 1,
      value: e.value.value,
      label: e.value.label,
      isCurrentUser: e.value.isCurrentUser,
    )).toList();
  },
);
