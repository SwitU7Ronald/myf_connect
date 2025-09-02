import 'package:cloud_firestore/cloud_firestore.dart';

class CleanupService {
  static Future<void> cleanupIncompleteUsers() async {
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('firstName', isNull: true)
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in usersSnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
