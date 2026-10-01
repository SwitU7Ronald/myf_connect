import 'package:cloud_firestore/cloud_firestore.dart';

class AdminRepository {
  final FirebaseFirestore _firestore;

  AdminRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Camps ────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getCampsStream() {
    return _firestore.collection('camps').orderBy('date').snapshots();
  }

  Future<void> createCamp(Map<String, dynamic> data) async {
    await _firestore.collection('camps').add(data);
  }

  Future<void> updateCamp(String id, Map<String, dynamic> data) async {
    await _firestore.collection('camps').doc(id).update(data);
  }

  Future<void> deleteCamp(String id) async {
    // Delete all events in this camp
    final eventsRef = _firestore
        .collection('camps')
        .doc(id)
        .collection('events');

    final eventsSnap = await eventsRef.get();

    if (eventsSnap.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in eventsSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    // Delete camp
    await _firestore.collection('camps').doc(id).delete();
  }

  // ── MYFs ─────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getMyfsStream() {
    return _firestore.collection('myfs').snapshots();
  }

  Future<void> createMyf(Map<String, dynamic> data) async {
    await _firestore.collection('myfs').add(data);
  }

  Future<void> updateMyf(String id, Map<String, dynamic> data) async {
    await _firestore.collection('myfs').doc(id).update(data);
  }

  Future<void> deleteMyf(String id) async {
    // Delete all events in this MYF
    final eventsRef = _firestore
        .collection('myfs')
        .doc(id)
        .collection('events');

    final eventsSnap = await eventsRef.get();

    if (eventsSnap.docs.isNotEmpty) {
      final batch = _firestore.batch();
      for (var doc in eventsSnap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }

    // Delete MYF
    await _firestore.collection('myfs').doc(id).delete();
  }

  // ── Events ───────────────────────────────────────────────────────

  Stream<QuerySnapshot> getEventsStream(String collection, String parentId) {
    return _firestore
        .collection(collection)
        .doc(parentId)
        .collection('events')
        .orderBy('dateTime')
        .snapshots();
  }

  Future<void> createEvent(
    String collection,
    String parentId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(collection)
        .doc(parentId)
        .collection('events')
        .add(data);
  }

  Future<void> updateEvent(
    String collection,
    String parentId,
    String eventId,
    Map<String, dynamic> data,
  ) async {
    await _firestore
        .collection(collection)
        .doc(parentId)
        .collection('events')
        .doc(eventId)
        .update(data);
  }

  Future<void> deleteEvent(
    String collection,
    String parentId,
    String eventId,
  ) async {
    await _firestore
        .collection(collection)
        .doc(parentId)
        .collection('events')
        .doc(eventId)
        .delete();
  }

  // ── Users ────────────────────────────────────────────────────────

  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  Future<void> grantPermission(String uid, String itemToGrant) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.update({
      'permissions': FieldValue.arrayUnion([itemToGrant]),
    });
  }

  Future<void> revokePermission(String uid, String itemToRevoke) async {
    final ref = _firestore.collection('users').doc(uid);
    await ref.update({
      'permissions': FieldValue.arrayRemove([itemToRevoke]),
    });
  }
}
