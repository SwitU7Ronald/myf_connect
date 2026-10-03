import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/core/services/auth/auth_repository.dart';
import 'package:myf_connect/core/models/app_user.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AuthRepository repository;
  late MockFirebaseAuth mockAuth;
  late MockGoogleSignIn mockGoogleSignIn;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;
  late MockGoogleSignInAccount mockGoogleAccount;
  late MockGoogleSignInAuthentication mockGoogleAuth;
  late MockUserCredential mockUserCredential;
  late MockAdditionalUserInfo mockAdditionalUserInfo;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    mockGoogleAccount = MockGoogleSignInAccount();
    mockGoogleAuth = MockGoogleSignInAuthentication();
    mockUserCredential = MockUserCredential();
    mockAdditionalUserInfo = MockAdditionalUserInfo();

    repository = AuthRepository(
      firebaseAuth: mockAuth,
      googleSignIn: mockGoogleSignIn,
      userRepository: mockUserRepository,
    );
  });

  group('AuthRepository', () {
    test('authStateChanges returns stream', () {
      when(
        mockAuth.authStateChanges(),
      ).thenAnswer((_) => Stream.value(mockUser));
      expect(repository.authStateChanges, emits(mockUser));
    });

    test('currentUser returns current user', () {
      when(mockAuth.currentUser).thenReturn(mockUser);
      expect(repository.currentUser, mockUser);
    });

    test('signInWithGoogle returns success if profile is complete', () async {
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async {});
      when(
        mockGoogleSignIn.authenticate(),
      ).thenAnswer((_) async => mockGoogleAccount);
      when(mockGoogleAccount.email).thenReturn('test@test.com');
      when(mockGoogleAccount.authentication).thenReturn(mockGoogleAuth);
      when(mockGoogleAuth.idToken).thenReturn('token');
      when(
        mockAuth.signInWithCredential(any),
      ).thenAnswer((_) async => mockUserCredential);
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('1');
      when(
        mockUserCredential.additionalUserInfo,
      ).thenReturn(mockAdditionalUserInfo);
      when(mockAdditionalUserInfo.isNewUser).thenReturn(false);

      final appUser = AppUser(
        uid: '1',
        email: 'test@test.com',
        phone: '123',
        firstName: 'First',
        lastName: 'Last',
        birthdate: DateTime.now(),
        gender: 'Male',
        district: 'District',
        church: 'Church',
      );

      when(mockUserRepository.getUser('1')).thenAnswer((_) async => appUser);

      final result = await repository.signInWithGoogle();

      expect(result.status, AuthStatus.success);
      expect(result.user, mockUser);
      expect(result.appUser, appUser);
    });

    test(
      'signInWithGoogle returns needsProfileCompletion if profile incomplete',
      () async {
        when(
          mockGoogleSignIn.initialize(
            clientId: anyNamed('clientId'),
            serverClientId: anyNamed('serverClientId'),
          ),
        ).thenAnswer((_) async {});
        when(
          mockGoogleSignIn.authenticate(),
        ).thenAnswer((_) async => mockGoogleAccount);
        when(mockGoogleAccount.email).thenReturn('test@test.com');
        when(mockGoogleAccount.authentication).thenReturn(mockGoogleAuth);
        when(mockGoogleAuth.idToken).thenReturn('token');
        when(
          mockAuth.signInWithCredential(any),
        ).thenAnswer((_) async => mockUserCredential);
        when(mockUserCredential.user).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('1');
        when(
          mockUserCredential.additionalUserInfo,
        ).thenReturn(mockAdditionalUserInfo);
        when(mockAdditionalUserInfo.isNewUser).thenReturn(true);

        final appUser = AppUser(uid: '1', phone: '123');

        when(mockUserRepository.getUser('1')).thenAnswer((_) async => appUser);

        final result = await repository.signInWithGoogle();

        expect(result.status, AuthStatus.needsProfileCompletion);
        expect(result.user, mockUser);
        expect(result.isNewUser, true);
      },
    );

    test('signOut signs out of google and firebase', () async {
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async {});
      when(mockGoogleSignIn.disconnect()).thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});
      when(mockAuth.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(mockGoogleSignIn.disconnect()).called(1);
      verify(mockGoogleSignIn.signOut()).called(1);
      verify(mockAuth.signOut()).called(1);
    });

    test('deleteIncompleteAccount deletes user and auth', () async {
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('1');
      when(
        mockGoogleSignIn.initialize(
          clientId: anyNamed('clientId'),
          serverClientId: anyNamed('serverClientId'),
        ),
      ).thenAnswer((_) async {});
      when(mockGoogleSignIn.disconnect()).thenAnswer((_) async {});
      when(mockGoogleSignIn.signOut()).thenAnswer((_) async {});
      when(mockUser.delete()).thenAnswer((_) async {});

      await repository.deleteIncompleteAccount();

      verify(mockUser.delete()).called(1);
    });
  });
}
