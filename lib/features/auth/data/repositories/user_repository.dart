import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/core/constants/app_constants.dart';

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection(AppConstants.usersCollection);
  Future<AppUser?> getUser(String uid) async {
    final doc = await _col.doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromMap(doc.id, doc.data()!);
  }

  Stream<AppUser?> getUserStream(String uid) {
    return _col.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppUser.fromMap(doc.id, doc.data()!);
    });
  }

  Future<void> createOrUpdateUser(
    AppUser user, {
    bool createIfMissing = true,
  }) async {
    final ref = _col.doc(user.uid);
    final snap = await ref.get();
    final payload = {...user.toMap()}..remove('permissions');
    if (!snap.exists) {
      if (!createIfMissing) return;
      await ref.set({
        ...payload,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await ref.update({...payload, 'updatedAt': FieldValue.serverTimestamp()});
    }
  }
}
