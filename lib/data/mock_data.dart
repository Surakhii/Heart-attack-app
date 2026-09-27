import 'dart:math';
import '../models/log_entry.dart';
import '../models/user_model.dart';
import 'flavors_data.dart';

final mockUsers = [
  UserModel(
    uid: 'uid_surakhii',
    displayName: 'surakhii',
    joinedAt: DateTime(2026, 5, 1),
  ),
  UserModel(
    uid: 'uid_sunshine',
    displayName: 'sunshine',
    joinedAt: DateTime(2026, 5, 1),
  ),
];

List<LogEntry> _generateLogs(String uid, int seed) {
  final rng = Random(seed);
  final logs = <LogEntry>[];
  final now = DateTime.now();
  int id = 0;

  for (int daysAgo = 29; daysAgo >= 0; daysAgo--) {
    final day = now.subtract(Duration(days: daysAgo));
    // skip ~20% of days to make streaks interesting
    if (rng.nextDouble() < 0.2) continue;

    final count = rng.nextInt(3) + 1;
    for (int i = 0; i < count; i++) {
      final flavor = allFlavors[rng.nextInt(allFlavors.length)];
      final size = flavor.sizes[rng.nextInt(flavor.sizes.length)];
      final hour = 14 + rng.nextInt(8); // 2pm–9pm
      final minute = rng.nextInt(60);

      logs.add(LogEntry(
        id: '${uid}_${id++}',
        uid: uid,
        flavorId: flavor.id,
        flavorName: '${flavor.brandName} ${flavor.name}',
        brandId: flavor.brand.name,
        sizeML: size.ml,
        caffeineMg: size.caffeineMg,
        timestamp: DateTime(day.year, day.month, day.day, hour, minute),
      ));
    }
  }

  return logs..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

final List<LogEntry> mockLogs = [
  ..._generateLogs('uid_surakhii', 42),
  ..._generateLogs('uid_sunshine', 99),
];
