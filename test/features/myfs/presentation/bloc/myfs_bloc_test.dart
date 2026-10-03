import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/myfs/presentation/bloc/myfs_bloc.dart';
import 'package:myf_connect/core/models/myf.dart';
import 'package:myf_connect/core/models/app_user.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late MyfsBloc myfsBloc;
  late MockMyfsRepository mockMyfsRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;
  late MockUser mockUser;

  setUp(() {
    mockMyfsRepository = MockMyfsRepository();
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();
    mockUser = MockUser();

    when(mockUser.uid).thenReturn('user1');

    myfsBloc = MyfsBloc(
      myfsRepository: mockMyfsRepository,
      userRepository: mockUserRepository,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    myfsBloc.close();
  });

  group('MyfsBloc', () {
    final tMyf = Myf(id: '1', title: 'Myf 1', description: 'Desc 1');

    final tAppUser = AppUser(
      uid: 'user1',
      email: 'test@example.com',
      phone: '1234567890',
      permissions: const ['1', '2'],
    );

    test('initial state is correct', () {
      expect(myfsBloc.state, const MyfsState());
    });

    blocTest<MyfsBloc, MyfsState>(
      'emits [loading, success] when subscription succeeds and user is unauthenticated',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(
          mockMyfsRepository.getMyfs(),
        ).thenAnswer((_) => Stream.value([tMyf]));
        return myfsBloc;
      },
      act: (bloc) => bloc.add(MyfsSubscriptionRequested()),
      expect: () => [
        const MyfsState(status: MyfsStatus.loading),
        MyfsState(
          status: MyfsStatus.success,
          myfs: [tMyf],
          userPermissions: const [],
        ),
      ],
    );

    blocTest<MyfsBloc, MyfsState>(
      'emits [loading, success] when subscription succeeds and user is authenticated',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(mockUser);
        when(
          mockUserRepository.getUserStream('user1'),
        ).thenAnswer((_) => Stream.value(tAppUser));
        when(
          mockMyfsRepository.getMyfs(),
        ).thenAnswer((_) => Stream.value([tMyf]));
        return myfsBloc;
      },
      act: (bloc) => bloc.add(MyfsSubscriptionRequested()),
      expect: () => [
        const MyfsState(status: MyfsStatus.loading),
        MyfsState(
          status: MyfsStatus.success,
          myfs: [tMyf],
          userPermissions: const [],
        ),
        MyfsState(
          status: MyfsStatus.success,
          myfs: [tMyf],
          userPermissions: const ['1', '2'],
        ),
      ],
    );

    blocTest<MyfsBloc, MyfsState>(
      'emits [loading, failure] when subscription fails',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(
          mockMyfsRepository.getMyfs(),
        ).thenAnswer((_) => Stream.error(Exception('error')));
        return myfsBloc;
      },
      act: (bloc) => bloc.add(MyfsSubscriptionRequested()),
      expect: () => [
        const MyfsState(status: MyfsStatus.loading),
        const MyfsState(
          status: MyfsStatus.failure,
          errorMessage: 'Exception: error',
        ),
      ],
    );
  });
}
