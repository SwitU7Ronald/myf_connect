import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/core/services/auth/auth_bloc.dart';
import 'package:myf_connect/core/services/auth/auth_repository.dart';
import 'package:myf_connect/core/models/app_user.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;
  late MockUserRepository mockUserRepository;
  late MockUser mockUser;
  late MockIdTokenResult mockIdTokenResult;

  final tAppUser = AppUser(
    uid: '123',
    email: 'test@example.com',
    firstName: 'John',
    lastName: 'Doe',
    phone: '1234567890',
    birthdate: DateTime(1990),
    gender: 'Male',
    district: 'North',
    church: 'Main',
    createdAt: DateTime.now(),
  );

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    mockUserRepository = MockUserRepository();
    mockUser = MockUser();
    mockIdTokenResult = MockIdTokenResult();

    when(mockUser.uid).thenReturn('123');

    authBloc = AuthBloc(
      authRepository: mockAuthRepository,
      userRepository: mockUserRepository,
    );
  });

  tearDown(() {
    authBloc.close();
  });

  group('AuthBloc', () {
    test('initial state is AuthInitial', () {
      expect(authBloc.state, isA<AuthInitial>());
    });

    blocTest<AuthBloc, AuthState>(
      'AuthCheckRequested emits [AuthLoading, AuthUnauthenticated] when user is null',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthCheckRequested emits [AuthLoading, AuthNeedsProfileCompletion] when user is signed in but appUser null',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(mockUserRepository.getUser('123')).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthNeedsProfileCompletion>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthCheckRequested emits [AuthLoading, AuthAuthenticated] when profile complete',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(
          mockUserRepository.getUser('123'),
        ).thenAnswer((_) async => tAppUser);
        when(
          mockUser.getIdTokenResult(true),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(mockIdTokenResult.claims).thenReturn({'admin': true});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (state) => state.isAdmin,
          'isAdmin',
          true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthCheckRequested emits [AuthLoading, AuthError, AuthUnauthenticated] on error',
      build: () {
        when(mockAuthRepository.currentUser).thenThrow(Exception('test'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLoginRequested emits [AuthLoading, AuthAuthenticated] on success',
      build: () {
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => AuthResult.success(mockUser, tAppUser));
        when(
          mockUser.getIdTokenResult(true),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(mockIdTokenResult.claims).thenReturn({'admin': false});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>().having(
          (state) => state.isAdmin,
          'isAdmin',
          false,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLoginRequested emits [AuthLoading, AuthNeedsProfileCompletion] on needsProfileCompletion',
      build: () {
        when(mockAuthRepository.signInWithGoogle()).thenAnswer(
          (_) async => AuthResult.needsProfileCompletion(mockUser, true),
        );
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthNeedsProfileCompletion>().having(
          (state) => state.isNewUser,
          'isNewUser',
          true,
        ),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLoginRequested emits [AuthLoading, AuthUnauthenticated] on cancelled',
      build: () {
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => AuthResult.cancelled());
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLoginRequested emits [AuthLoading, AuthError, AuthUnauthenticated] on error',
      build: () {
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenAnswer((_) async => AuthResult.error('error'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLoginRequested emits [AuthLoading, AuthError, AuthUnauthenticated] on exception',
      build: () {
        when(
          mockAuthRepository.signInWithGoogle(),
        ).thenThrow(Exception('test'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLoginRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLogoutRequested emits [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthLogoutRequested emits [AuthLoading, AuthError, AuthUnauthenticated] on error',
      build: () {
        when(mockAuthRepository.signOut()).thenThrow(Exception('test'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(),
      ],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthDeleteAccountRequested emits [AuthLoading, AuthUnauthenticated]',
      build: () {
        when(
          mockAuthRepository.deleteIncompleteAccount(),
        ).thenAnswer((_) async {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthDeleteAccountRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'AuthDeleteAccountRequested emits [AuthLoading, AuthError, AuthUnauthenticated] on error',
      build: () {
        when(
          mockAuthRepository.deleteIncompleteAccount(),
        ).thenThrow(Exception('test'));
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthDeleteAccountRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>(),
        isA<AuthUnauthenticated>(),
      ],
    );
  });
}
