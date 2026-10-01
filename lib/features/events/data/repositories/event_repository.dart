import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/features/events/data/models/event.dart';

/// Repository for fetching and rating events for both Camps and MYFs.
///
/// Uses a [collection] string (e.g. 'camps' or 'myfs') to parameterise
/// queries, avoiding parallel repository methods for each parent type.
class EventRepository {
  final FirebaseFirestore _firestore;

  EventRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Generic helpers ───────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> _eventsCol(
    String collection,
    String parentId,
  ) =>
      _firestore
          .collection(collection)
          .doc(parentId)
          .collection('events');

  // ── All Events ────────────────────────────────────────────────────

  /// Returns a real-time stream of all events for a given parent document.
  Stream<List<AppEvent>> getAllEvents(String collection, String parentId) {
    return _eventsCol(collection, parentId)
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => AppEvent.fromMap(doc.id, doc.data())).toList(),
        );
  }

  /// Returns a stream of upcoming events (dateTime ≥ now).
  Stream<List<AppEvent>> getUpcomingEvents(String collection, String parentId) {
    return _eventsCol(collection, parentId)
        .where('dateTime', isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy('dateTime')
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => AppEvent.fromMap(doc.id, doc.data())).toList(),
        );
  }

  /// Returns a stream of past events (dateTime < now), descending.
  Stream<List<AppEvent>> getPastEvents(String collection, String parentId) {
    return _eventsCol(collection, parentId)
        .where('dateTime', isLessThan: Timestamp.now())
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((doc) => AppEvent.fromMap(doc.id, doc.data())).toList(),
        );
  }

  // ── Average Rating ────────────────────────────────────────────────

  /// Returns a stream of the average rating data for a parent (camp or MYF).
  ///
  /// Consolidates the duplicate logic previously in [CampsRepository] and
  /// [MyfsRepository]. The returned map contains 'avgRating' and 'count'.
  Stream<Map<String, double>> getAverageRating(
    String collection,
    String parentId,
  ) {
    return _eventsCol(collection, parentId)
        .where('dateTime', isLessThan: Timestamp.now())
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isEmpty) {
            return {'avgRating': 0.0, 'count': 0.0};
          }

          double totalRating = 0.0;
          int eventCount = 0;

          for (final doc in snapshot.docs) {
            final data = doc.data();
            final avgRating = (data['avgRating'] ?? 0.0).toDouble();
            final numRatings = data['numRatings'] ?? 0;
            if (numRatings > 0) {
              totalRating += avgRating;
              eventCount++;
            }
          }

          return {
            'avgRating': eventCount > 0 ? totalRating / eventCount : 0.0,
            'count': eventCount.toDouble(),
          };
        });
  }

  // ── User Rating ───────────────────────────────────────────────────

  /// Check if user has already rated an event. Returns the rating value or null.
  Future<int?> getUserRating({
    required String collection,
    required String parentId,
    required String eventId,
    required String userId,
  }) async {
    final ratingsSnapshot = await _eventsCol(collection, parentId)
        .doc(eventId)
        .collection('ratings')
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (ratingsSnapshot.docs.isNotEmpty) {
      return ratingsSnapshot.docs.first.data()['rating'] as int;
    }
    return null;
  }

  /// Submit or update a rating for an event using a Firestore transaction.
  Future<void> submitRating({
    required String collection,
    required String parentId,
    required String eventId,
    required String userId,
    required int rating,
  }) async {
    final eventRef = _eventsCol(collection, parentId).doc(eventId);

    await _firestore.runTransaction((transaction) async {
      final freshEventSnapshot = await transaction.get(eventRef);

      if (!freshEventSnapshot.exists) {
        throw Exception('Event document was deleted during transaction');
      }

      final ratingRef = eventRef.collection('ratings').doc(userId);
      final ratingSnap = await transaction.get(ratingRef);

      final eventData = freshEventSnapshot.data();
      final oldAvgRating = _safeToDouble(eventData?['avgRating'], 0.0);
      final oldCount = _safeToInt(eventData?['numRatings'], 0);

      double newAvgRating;
      int newCount;

      if (ratingSnap.exists) {
        // User is updating their existing rating
        final oldUserRating = _safeToInt(ratingSnap.data()?['rating'], 0);
        newCount = oldCount;
        if (oldCount <= 0) {
          newAvgRating = rating.toDouble();
          newCount = 1;
        } else {
          newAvgRating =
              (oldAvgRating * oldCount - oldUserRating + rating) / oldCount;
        }
      } else {
        // New rating submission
        newCount = oldCount + 1;
        newAvgRating = (oldAvgRating * oldCount + rating) / newCount;
      }

      transaction.update(eventRef, {
        'avgRating': newAvgRating,
        'numRatings': newCount,
      });

      transaction.set(ratingRef, {
        'userId': userId,
        'rating': rating,
        'timestamp': FieldValue.serverTimestamp(),
      });
    });
  }

  // ── Private Helpers ───────────────────────────────────────────────

  double _safeToDouble(dynamic value, double defaultValue) {
    if (value == null) return defaultValue;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? defaultValue;
    return defaultValue;
  }

  int _safeToInt(dynamic value, int defaultValue) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? defaultValue;
    return defaultValue;
  }
}
