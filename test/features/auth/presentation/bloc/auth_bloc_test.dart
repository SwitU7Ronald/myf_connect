import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/auth/data/models/app_user.dart';

import 'auth_bloc_test.mocks.dart';

@GenerateMocks([AuthRepository, UserRepository, User, IdTokenResult])
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
      'emits [AuthLoading, AuthUnauthenticated] when user is not signed in',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthNeedsProfileCompletion] when user is signed in but not in database',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(mockUserRepository.getUser('123')).thenAnswer((_) async => null);
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthNeedsProfileCompletion>()],
    );

    blocTest<AuthBloc, AuthState>(
      'emits [AuthLoading, AuthAuthenticated] when user is fully authenticated and profile complete',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(
          mockUserRepository.getUser('123'),
        ).thenAnswer((_) async => tAppUser);
        when(
          mockUser.getIdTokenResult(true),
        ).thenAnswer((_) async => mockIdTokenResult);
        when(mockIdTokenResult.claims).thenReturn({'admin': false});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthCheckRequested()),
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
      'emits [AuthLoading, AuthUnauthenticated] on AuthLogoutRequested',
      build: () {
        when(mockAuthRepository.signOut()).thenAnswer((_) async => {});
        return authBloc;
      },
      act: (bloc) => bloc.add(AuthLogoutRequested()),
      expect: () => [isA<AuthLoading>(), isA<AuthUnauthenticated>()],
    );
  });
}
