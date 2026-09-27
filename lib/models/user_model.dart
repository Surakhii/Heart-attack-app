class UserModel {
  final String uid;
  final String displayName;
  final String? photoURL;
  final DateTime joinedAt;

  const UserModel({
    required this.uid,
    required this.displayName,
    this.photoURL,
    required this.joinedAt,
  });

  String get initials {
    final parts = displayName.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';
  }
}
