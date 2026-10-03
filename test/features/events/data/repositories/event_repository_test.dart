import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myf_connect/core/models/event.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
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
  Query<Map<String, dynamic>> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    return this;
  }

  @override
  Query<Map<String, dynamic>> orderBy(Object field, {bool descending = false}) {
    return this;
  }

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> get([GetOptions? options]) async {
    return snapshot;
  }

  @override
  Query<Map<String, dynamic>> limit(int limit) {
    return this;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeTransaction implements Transaction {
  final MockDocumentSnapshot<Map<String, dynamic>> snap;
  FakeTransaction(this.snap);

  @override
  Future<DocumentSnapshot<T>> get<T extends Object?>(
    DocumentReference<T> documentReference,
  ) async {
    return snap as DocumentSnapshot<T>;
  }

  @override
  Transaction delete(DocumentReference documentReference) => this;

  @override
  Transaction update(
    DocumentReference documentReference,
    Map<Object, Object?> data,
  ) => this;

  @override
  Transaction set<T extends Object?>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) => this;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late EventRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockCollectionReference<Map<String, dynamic>> mockEventsCollection;
  late MockCollectionReference<Map<String, dynamic>> mockRatingsCollection;
  late MockDocumentReference<Map<String, dynamic>> mockParentDocRef;
  late MockDocumentReference<Map<String, dynamic>> mockEventDocRef;
  late MockDocumentReference<Map<String, dynamic>> mockRatingDocRef;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late MockDocumentSnapshot<Map<String, dynamic>> mockSingleDocSnapshot;
  late FakeQuery fakeQuery;
  late FakeTransaction fakeTransaction;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockEventsCollection = MockCollectionReference();
    mockRatingsCollection = MockCollectionReference();
    mockParentDocRef = MockDocumentReference();
    mockEventDocRef = MockDocumentReference();
    mockRatingDocRef = MockDocumentReference();
    mockQuerySnapshot = MockQuerySnapshot();
    mockDocSnapshot = MockQueryDocumentSnapshot();
    mockSingleDocSnapshot = MockDocumentSnapshot();
    fakeQuery = FakeQuery(mockQuerySnapshot);
    fakeTransaction = FakeTransaction(mockSingleDocSnapshot);

    when(mockFirestore.collection(any)).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockParentDocRef);
    when(
      mockParentDocRef.collection('events'),
    ).thenReturn(mockEventsCollection);

    when(
      mockEventsCollection.orderBy(any, descending: anyNamed('descending')),
    ).thenReturn(fakeQuery);
    when(
      mockEventsCollection.where(
        any,
        isLessThan: anyNamed('isLessThan'),
        isGreaterThanOrEqualTo: anyNamed('isGreaterThanOrEqualTo'),
      ),
    ).thenReturn(fakeQuery);

    when(mockEventsCollection.doc(any)).thenReturn(mockEventDocRef);
    when(
      mockEventDocRef.collection('ratings'),
    ).thenReturn(mockRatingsCollection);
    when(
      mockRatingsCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
    ).thenReturn(fakeQuery);
    when(mockRatingsCollection.doc(any)).thenReturn(mockRatingDocRef);

    repository = EventRepository(firestore: mockFirestore);
  });

  group('EventRepository', () {
    test('getAllEvents returns stream', () {
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.id).thenReturn('1');
      when(mockDocSnapshot.data()).thenReturn({
        'title': 'Test',
        'dateTime': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      expect(
        repository.getAllEvents('camps', '1'),
        emits([
          isA<AppEvent>()
              .having((e) => e.id, 'id', '1')
              .having((e) => e.title, 'title', 'Test'),
        ]),
      );
    });

    test('getUpcomingEvents returns stream', () {
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.id).thenReturn('1');
      when(mockDocSnapshot.data()).thenReturn({
        'title': 'Upcoming',
        'dateTime': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      expect(
        repository.getUpcomingEvents('camps', '1'),
        emits([
          isA<AppEvent>()
              .having((e) => e.id, 'id', '1')
              .having((e) => e.title, 'title', 'Upcoming'),
        ]),
      );
    });

    test('getPastEvents returns stream', () {
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.id).thenReturn('1');
      when(mockDocSnapshot.data()).thenReturn({
        'title': 'Past',
        'dateTime': Timestamp.fromDate(DateTime(2023, 1, 1)),
      });

      expect(
        repository.getPastEvents('camps', '1'),
        emits([
          isA<AppEvent>()
              .having((e) => e.id, 'id', '1')
              .having((e) => e.title, 'title', 'Past'),
        ]),
      );
    });

    test('getAverageRating calculates correctly', () {
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(
        mockDocSnapshot.data(),
      ).thenReturn({'avgRating': 4.5, 'numRatings': 2});

      expect(
        repository.getAverageRating('camps', '1'),
        emits({'avgRating': 4.5, 'count': 1.0}),
      );
    });

    test('getUserRating returns rating if exists', () async {
      when(mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(mockDocSnapshot.data()).thenReturn({'rating': 5});

      final rating = await repository.getUserRating(
        collection: 'camps',
        parentId: '1',
        eventId: '1',
        userId: '1',
      );

      expect(rating, 5);
    });

    test('getUserRating returns null if not exists', () async {
      when(mockQuerySnapshot.docs).thenReturn([]);

      final rating = await repository.getUserRating(
        collection: 'camps',
        parentId: '1',
        eventId: '1',
        userId: '1',
      );

      expect(rating, isNull);
    });

    test('submitRating runs transaction', () async {
      when(mockFirestore.runTransaction<void>(any)).thenAnswer((inv) async {
        final handler = inv.positionalArguments[0];
        await handler(fakeTransaction);
        return;
      });

      when(mockSingleDocSnapshot.exists).thenReturn(true);
      when(
        mockSingleDocSnapshot.data(),
      ).thenReturn({'avgRating': 4.0, 'numRatings': 1});

      await repository.submitRating(
        collection: 'camps',
        parentId: '1',
        eventId: '1',
        userId: '1',
        rating: 5,
      );
    });
  });
}
