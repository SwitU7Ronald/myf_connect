import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/app_user.dart';

class UserService {
  final _col = FirebaseFirestore.instance.collection('users');

  Future<AppUser?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Future<void> createOrUpdateUser(
      AppUser user, {
        bool createIfMissing = true,
      }) async {
    final ref = _col.doc(user.uid);
    final snap = await ref.get();

    // Only safe, self-writable fields (rules allow these for self)
    final payload = {
      ...user.toMap(),
    }..remove('permissions'); // self cannot write 'permissions'

    if (!snap.exists) {
      if (!createIfMissing) return;
      await ref.set({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({
        ...payload,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
