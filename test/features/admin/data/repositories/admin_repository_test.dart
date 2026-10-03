import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
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

class FakeWriteBatch implements WriteBatch {
  bool committed = false;
  List<DocumentReference> deleted = [];

  @override
  void delete(DocumentReference document) {
    deleted.add(document);
  }

  @override
  Future<void> commit() async {
    committed = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late AdminRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockCollectionReference<Map<String, dynamic>> mockSubCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late FakeQuery fakeQuery;
  late FakeWriteBatch mockBatch;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockSubCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();
    fakeQuery = FakeQuery(mockQuerySnapshot);
    mockBatch = FakeWriteBatch();

    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocRef);
    when(mockDocRef.collection(any)).thenReturn(mockSubCollection);
    when(
      mockCollection.orderBy(any),
    ).thenReturn(fakeQuery as Query<Map<String, dynamic>>);
    when(
      mockSubCollection.orderBy(any),
    ).thenReturn(fakeQuery as Query<Map<String, dynamic>>);
    when(mockFirestore.batch()).thenReturn(mockBatch);

    repository = AdminRepository(firestore: mockFirestore);
  });

  group('AdminRepository - Camps', () {
    test('getCampsStream returns stream', () {
      final stream = repository.getCampsStream();
      expect(stream, isA<Stream<QuerySnapshot>>());
    });

    test('createCamp adds document', () async {
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
      await repository.createCamp({'title': 'New Camp'});
      verify(mockCollection.add({'title': 'New Camp'})).called(1);
    });

    test('updateCamp updates document', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => {});
      await repository.updateCamp('1', {'title': 'Updated'});
      verify(mockDocRef.update({'title': 'Updated'})).called(1);
    });

    test('deleteCamp deletes events and camp', () async {
      when(mockSubCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.reference).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async => {});

      await repository.deleteCamp('1');

      expect(mockBatch.deleted.contains(mockDocRef), true);
      expect(mockBatch.committed, true);
      verify(mockDocRef.delete()).called(1);
    });
  });

  group('AdminRepository - Myfs', () {
    test('getMyfsStream returns stream', () {
      when(
        mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      final stream = repository.getMyfsStream();
      expect(stream, isA<Stream<QuerySnapshot>>());
    });

    test('createMyf adds document', () async {
      when(mockCollection.add(any)).thenAnswer((_) async => mockDocRef);
      await repository.createMyf({'title': 'New MYF'});
      verify(mockCollection.add({'title': 'New MYF'})).called(1);
    });

    test('updateMyf updates document', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => {});
      await repository.updateMyf('1', {'title': 'Updated MYF'});
      verify(mockDocRef.update({'title': 'Updated MYF'})).called(1);
    });

    test('deleteMyf deletes events and myf', () async {
      when(mockSubCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.reference).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async => {});

      await repository.deleteMyf('1');

      expect(mockBatch.deleted.contains(mockDocRef), true);
      expect(mockBatch.committed, true);
      verify(mockDocRef.delete()).called(1);
    });
  });

  group('AdminRepository - Events', () {
    test('getEventsStream returns stream', () {
      final stream = repository.getEventsStream('camps', '1');
      expect(stream, isA<Stream<QuerySnapshot>>());
    });

    test('createEvent adds document', () async {
      when(mockSubCollection.add(any)).thenAnswer((_) async => mockDocRef);
      await repository.createEvent('camps', '1', {'title': 'Event'});
      verify(mockSubCollection.add({'title': 'Event'})).called(1);
    });

    test('updateEvent updates document', () async {
      when(mockSubCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.update(any)).thenAnswer((_) async => {});
      await repository.updateEvent('camps', '1', '2', {'title': 'Updated'});
      verify(mockDocRef.update({'title': 'Updated'})).called(1);
    });

    test('deleteEvent deletes document', () async {
      when(mockSubCollection.doc(any)).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async => {});
      await repository.deleteEvent('camps', '1', '2');
      verify(mockDocRef.delete()).called(1);
    });
  });

  group('AdminRepository - Users', () {
    test('getUsersStream returns stream', () {
      when(
        mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      final stream = repository.getUsersStream();
      expect(stream, isA<Stream<QuerySnapshot>>());
    });

    test('grantPermission updates user', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => {});
      await repository.grantPermission('1', 'admin');
      verify(
        mockDocRef.update({
          'permissions': FieldValue.arrayUnion(['admin']),
        }),
      ).called(1);
    });

    test('revokePermission updates user', () async {
      when(mockDocRef.update(any)).thenAnswer((_) async => {});
      await repository.revokePermission('1', 'admin');
      verify(
        mockDocRef.update({
          'permissions': FieldValue.arrayRemove(['admin']),
        }),
      ).called(1);
    });
  });
}
