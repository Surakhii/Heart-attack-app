import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/log_entry.dart';
import '../models/user_model.dart';

class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  // ── Invite codes ────────────────────────────────────────────────────────────

  static Future<bool> validateInviteCode(String code) async {
    final q = await _db
        .collection('inviteCodes')
        .where('code', isEqualTo: code.trim().toLowerCase())
        .limit(1)
        .get();
    return q.docs.isNotEmpty;
  }

  // ── Users ───────────────────────────────────────────────────────────────────

  static Future<void> createUserDoc(User firebaseUser) async {
    final ref = _db.collection('users').doc(firebaseUser.uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set({
        'displayName': firebaseUser.displayName ?? firebaseUser.email ?? 'unknown',
        'photoURL': firebaseUser.photoURL,
        'joinedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  static Future<bool> userDocExists(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    return snap.exists;
  }

  static Stream<UserModel?> currentUserStream(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return null;
      final d = snap.data()!;
      return UserModel(
        uid: uid,
        displayName: d['displayName'] as String,
        photoURL: d['photoURL'] as String?,
        joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      );
    });
  }

  static Future<UserModel?> getUser(String uid) async {
    final snap = await _db.collection('users').doc(uid).get();
    if (!snap.exists) return null;
    final d = snap.data()!;
    return UserModel(
      uid: uid,
      displayName: d['displayName'] as String,
      photoURL: d['photoURL'] as String?,
      joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static Future<void> updateDisplayName(String uid, String name) async {
    await _db.collection('users').doc(uid).update({'displayName': name});
  }

  static Future<String> uploadProfilePhoto(String uid, File file) async {
    final ref = FirebaseStorage.instance.ref('profiles/$uid/photo.jpg');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    await _db.collection('users').doc(uid).update({'photoURL': url});
    return url;
  }

  static Future<void> deleteUserData(String uid) async {
    final drinks = await _db.collection('logs').doc(uid).collection('drinks').get();
    for (final doc in drinks.docs) {
      await doc.reference.delete();
    }
    await _db.collection('users').doc(uid).delete();
  }

  static Stream<List<UserModel>> allUsersStream() {
    return _db.collection('users').snapshots().map((snap) => snap.docs
        .map((d) => UserModel(
              uid: d.id,
              displayName: d['displayName'] as String,
              photoURL: d['photoURL'] as String?,
              joinedAt: (d['joinedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
            ))
        .toList());
  }

  // ── Logs ────────────────────────────────────────────────────────────────────

  static Future<void> addLog(LogEntry entry) async {
    await _db
        .collection('logs')
        .doc(entry.uid)
        .collection('drinks')
        .doc(entry.id)
        .set({
      'flavorId': entry.flavorId,
      'flavorName': entry.flavorName,
      'brandId': entry.brandId,
      'sizeML': entry.sizeML,
      'caffeineMg': entry.caffeineMg,
      'timestamp': Timestamp.fromDate(entry.timestamp),
    });
  }

  static Stream<List<LogEntry>> userLogsStream(String uid) {
    return _db
        .collection('logs')
        .doc(uid)
        .collection('drinks')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => LogEntry(
                  id: d.id,
                  uid: uid,
                  flavorId: d['flavorId'] as String,
                  flavorName: d['flavorName'] as String,
                  brandId: d['brandId'] as String,
                  sizeML: d['sizeML'] as int,
                  caffeineMg: d['caffeineMg'] as int,
                  timestamp: (d['timestamp'] as Timestamp).toDate(),
                ))
            .toList());
  }
}
