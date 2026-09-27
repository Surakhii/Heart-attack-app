class LogEntry {
  final String id;
  final String uid;
  final String flavorId;
  final String flavorName;
  final String brandId;
  final int sizeML;
  final int caffeineMg;
  final DateTime timestamp;

  const LogEntry({
    required this.id,
    required this.uid,
    required this.flavorId,
    required this.flavorName,
    required this.brandId,
    required this.sizeML,
    required this.caffeineMg,
    required this.timestamp,
  });

  LogEntry copyWith({DateTime? timestamp}) => LogEntry(
    id: id,
    uid: uid,
    flavorId: flavorId,
    flavorName: flavorName,
    brandId: brandId,
    sizeML: sizeML,
    caffeineMg: caffeineMg,
    timestamp: timestamp ?? this.timestamp,
  );
}
