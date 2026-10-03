import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/models/camp.dart';

/// Abstract contract for the Camps data source.
///
/// Blocs/Cubits depend on this interface, not the concrete implementation,
/// satisfying the Dependency Inversion Principle.
abstract interface class CampsRepository {
  /// Returns a real-time stream of all camps ordered by date.
  Stream<List<Camp>> getCamps();
}

/// Concrete Firestore implementation of [CampsRepository].
class CampsRepositoryImpl implements CampsRepository {
  final FirebaseFirestore _firestore;

  CampsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Camp>> getCamps() {
    return _firestore
        .collection('camps')
        .orderBy('date')
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Camp.fromFirestore(doc)).toList(),
        );
  }
}
