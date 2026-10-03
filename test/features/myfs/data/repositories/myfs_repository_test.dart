import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/myfs/data/repositories/myfs_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/models/myf.dart';

import '../../../../helpers/test_helpers.mocks.dart';

// ignore: subtype_of_sealed_class
class FakeQuery implements Query<Map<String, dynamic>> {
  final MockQuerySnapshot<Map<String, dynamic>> snapshot;
  FakeQuery(this.snapshot);

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) {
    return Stream.value(snapshot);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MyfsRepositoryImpl repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late FakeQuery fakeQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockQuerySnapshot = MockQuerySnapshot();
    fakeQuery = FakeQuery(mockQuerySnapshot);
    mockDocumentSnapshot = MockQueryDocumentSnapshot();

    when(mockFirestore.collection('myfs')).thenReturn(mockCollection);
    when(
      mockCollection.orderBy('title'),
    ).thenReturn(fakeQuery as Query<Map<String, dynamic>>);

    repository = MyfsRepositoryImpl(firestore: mockFirestore);
  });

  group('MyfsRepository', () {
    test('getMyfs returns stream of myfs', () {
      when(mockQuerySnapshot.docs).thenReturn([mockDocumentSnapshot]);
      when(mockDocumentSnapshot.id).thenReturn('1');
      when(
        mockDocumentSnapshot.data(),
      ).thenReturn({'title': 'Test Myf', 'description': 'Test Desc'});

      expect(
        repository.getMyfs(),
        emits([Myf(id: '1', title: 'Test Myf', description: 'Test Desc')]),
      );
    });
  });
}
