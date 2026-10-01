import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';

import '../../../../helpers/test_helpers.mocks.dart';

// Create a Fake UserCredential
class MockUserCredential extends Mock implements UserCredential {
  @override
  User? get user => MockFirebaseUser();
}

class MockFirebaseUser extends Mock implements User {
  @override
  String get uid => 'test_uid_123';
  @override
  String? get email => 'test@example.com';
  @override
  String? get displayName => 'Test User';
}

void main() {
  late AuthRepository authRepository;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockGoogleSignIn mockGoogleSignIn;

  late MockUserRepository mockUserRepository;

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserRepository = MockUserRepository();
    authRepository = AuthRepository(
      firebaseAuth: mockFirebaseAuth,
      googleSignIn: mockGoogleSignIn,
      userRepository: mockUserRepository,
    );
  });

  group('AuthRepository', () {
    test('currentUser returns null when no user is signed in', () {
      when(mockFirebaseAuth.currentUser).thenReturn(null);
      expect(authRepository.currentUser, isNull);
    });

    test('currentUser returns User when signed in', () {
      final mockUser = MockFirebaseUser();
      when(mockFirebaseAuth.currentUser).thenReturn(mockUser);
      expect(authRepository.currentUser, equals(mockUser));
    });

    test('signOut successfully calls firebase and google sign out', () async {
      when(mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});

      await authRepository.signOut();

      verify(mockFirebaseAuth.signOut()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
    });
  });
}
