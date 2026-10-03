import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/core/models/app_user.dart';
import 'package:myf_connect/core/services/users/user_repository.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late UserRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDocRef;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference();
    mockDocRef = MockDocumentReference();
    mockDocSnapshot = MockDocumentSnapshot();

    when(mockFirestore.collection('users')).thenReturn(mockCollection);
    when(mockCollection.doc(any)).thenReturn(mockDocRef);

    repository = UserRepository(firestore: mockFirestore);
  });

  group('UserRepository', () {
    test('getUser returns user if exists', () async {
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.id).thenReturn('1');
      when(mockDocSnapshot.data()).thenReturn({'email': 'test@test.com'});

      final user = await repository.getUser('1');
      expect(user?.uid, '1');
      expect(user?.email, 'test@test.com');
    });

    test('getUser returns null if not exists', () async {
      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);

      final user = await repository.getUser('1');
      expect(user, isNull);
    });

    test('getUserStream returns stream of user if exists', () {
      when(
        mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocSnapshot.id).thenReturn('1');
      when(mockDocSnapshot.data()).thenReturn({'email': 'test@test.com'});

      expect(
        repository.getUserStream('1'),
        emits(isA<AppUser>().having((u) => u.email, 'email', 'test@test.com')),
      );
    });

    test('getUserStream returns stream of null if not exists', () {
      when(
        mockDocRef.snapshots(),
      ).thenAnswer((_) => Stream.value(mockDocSnapshot));
      when(mockDocSnapshot.exists).thenReturn(false);

      expect(repository.getUserStream('1'), emits(isNull));
    });

    test('createOrUpdateUser sets new user if missing', () async {
      final user = AppUser(uid: '1', email: 'test@test.com', phone: '123');

      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(false);
      when(mockDocRef.set(any)).thenAnswer((_) async => {});

      await repository.createOrUpdateUser(user, createIfMissing: true);
      verify(mockDocRef.set(any)).called(1);
    });

    test('createOrUpdateUser updates existing user', () async {
      final user = AppUser(uid: '1', email: 'test@test.com', phone: '123');

      when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
      when(mockDocSnapshot.exists).thenReturn(true);
      when(mockDocRef.update(any)).thenAnswer((_) async => {});

      await repository.createOrUpdateUser(user, createIfMissing: true);
      verify(mockDocRef.update(any)).called(1);
    });

    test(
      'createOrUpdateUser does not create if createIfMissing is false',
      () async {
        final user = AppUser(uid: '1', email: 'test@test.com', phone: '123');

        when(mockDocRef.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockDocSnapshot.exists).thenReturn(false);

        await repository.createOrUpdateUser(user, createIfMissing: false);
        verifyNever(mockDocRef.set(any));
      },
    );

    test('deleteUser deletes document', () async {
      when(mockDocRef.delete()).thenAnswer((_) async => {});

      await repository.deleteUser('1');
      verify(mockDocRef.delete()).called(1);
    });
  });
}
