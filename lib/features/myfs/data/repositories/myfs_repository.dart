import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/features/myfs/data/models/myf.dart';

/// Abstract contract for the MYFs data source.
///
/// Blocs/Cubits depend on this interface, not the concrete implementation,
/// satisfying the Dependency Inversion Principle.
abstract interface class MyfsRepository {
  /// Returns a real-time stream of all MYF groups ordered by title.
  Stream<List<Myf>> getMyfs();
}

/// Concrete Firestore implementation of [MyfsRepository].
class MyfsRepositoryImpl implements MyfsRepository {
  final FirebaseFirestore _firestore;

  MyfsRepositoryImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Myf>> getMyfs() {
    return _firestore.collection('myfs').orderBy('title').snapshots().map(
      (snapshot) =>
          snapshot.docs.map((doc) => Myf.fromFirestore(doc)).toList(),
    );
  }
}
