import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> createOrUpdateUser(AppUser user, {bool createIfMissing = true}) async {
    final ref = _col.doc(user.uid);
    final doc = await ref.get();
    final now = DateTime.now().toIso8601String();
    if (!doc.exists) {
      if (!createIfMissing) return;
      await ref.set({
        ...user.toMap(),
        'createdAt': now,
        'updatedAt': now,
      });
    } else {
      await ref.update({
        ...user.toMap(),
        'updatedAt': now,
      });
    }
  }
}
