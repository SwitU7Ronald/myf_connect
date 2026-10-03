import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/camps/presentation/bloc/camps_bloc.dart';
import 'package:myf_connect/core/models/camp.dart';
import 'package:myf_connect/core/models/app_user.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late CampsBloc campsBloc;
  late MockCampsRepository mockCampsRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;

  setUp(() {
    mockCampsRepository = MockCampsRepository();
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();

    when(mockUser.uid).thenReturn('user1');

    campsBloc = CampsBloc(
      campsRepository: mockCampsRepository,
      userRepository: mockUserRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    campsBloc.close();
  });

  group('CampsBloc', () {
    final tCamp = Camp(
      id: '1',
      title: 'Camp 1',
      description: 'Desc 1',
      place: 'Place 1',
      date: DateTime(2025),
    );

    final tAppUser = AppUser(
      uid: 'user1',
      email: 'test@example.com',
      phone: '1234567890',
      permissions: const ['1', '2'],
    );

    test('initial state is correct', () {
      expect(campsBloc.state, const CampsState());
    });

    blocTest<CampsBloc, CampsState>(
      'emits [loading, success] when subscription succeeds and user is unauthenticated',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(
          mockCampsRepository.getCamps(),
        ).thenAnswer((_) => Stream.value([tCamp]));
        return campsBloc;
      },
      act: (bloc) => bloc.add(CampsSubscriptionRequested()),
      expect: () => [
        const CampsState(status: CampsStatus.loading),
        CampsState(
          status: CampsStatus.success,
          camps: [tCamp],
          userPermissions: const [],
        ),
      ],
    );

    blocTest<CampsBloc, CampsState>(
      'emits [loading, success] when subscription succeeds and user is authenticated',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(
          mockUserRepository.getUserStream('user1'),
        ).thenAnswer((_) => Stream.value(tAppUser));
        when(
          mockCampsRepository.getCamps(),
        ).thenAnswer((_) => Stream.value([tCamp]));
        return campsBloc;
      },
      act: (bloc) => bloc.add(CampsSubscriptionRequested()),
      expect: () => [
        const CampsState(status: CampsStatus.loading),
        CampsState(
          status: CampsStatus.success,
          camps: [tCamp],
          userPermissions: const [],
        ),
        CampsState(
          status: CampsStatus.success,
          camps: [tCamp],
          userPermissions: const ['1', '2'],
        ),
      ],
    );

    blocTest<CampsBloc, CampsState>(
      'emits [loading, failure] when subscription fails',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(
          mockCampsRepository.getCamps(),
        ).thenAnswer((_) => Stream.error(Exception('error')));
        return campsBloc;
      },
      act: (bloc) => bloc.add(CampsSubscriptionRequested()),
      expect: () => [
        const CampsState(status: CampsStatus.loading),
        const CampsState(
          status: CampsStatus.failure,
          errorMessage: 'Exception: error',
        ),
      ],
    );
  });
}
