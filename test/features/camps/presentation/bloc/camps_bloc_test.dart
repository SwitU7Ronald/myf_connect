import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:myf_connect/features/camps/presentation/bloc/camps_bloc.dart';
import 'package:myf_connect/features/camps/data/repositories/camps_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/camps/data/models/camp.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'camps_bloc_test.mocks.dart';

@GenerateMocks([CampsRepository, UserRepository, AuthRepository, User])
void main() {
  late CampsBloc campsBloc;
  late MockCampsRepository mockCampsRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockCampsRepository = MockCampsRepository();
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();

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
    test('initial state is correct', () {
      expect(campsBloc.state, const CampsState());
    });

    blocTest<CampsBloc, CampsState>(
      'emits [loading, success] when subscription succeeds and user is unauthenticated',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(mockCampsRepository.getCamps()).thenAnswer(
          (_) => Stream.value([
            Camp(
              id: '1',
              title: 'Camp 1',
              description: 'Desc 1',
              place: 'Place 1',
              date: DateTime(2025),
            ),
          ]),
        );
        return campsBloc;
      },
      act: (bloc) => bloc.add(CampsSubscriptionRequested()),
      expect: () => [
        const CampsState(status: CampsStatus.loading),
        CampsState(
          status: CampsStatus.success,
          camps: [
            Camp(
              id: '1',
              title: 'Camp 1',
              description: 'Desc 1',
              place: 'Place 1',
              date: DateTime(2025),
            ),
          ],
          userPermissions: const [],
        ),
      ],
    );
  });
}
