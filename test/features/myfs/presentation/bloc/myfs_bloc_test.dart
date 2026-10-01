import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/myfs/presentation/bloc/myfs_bloc.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late MyfsBloc myfsBloc;
  late MockMyfsRepository mockMyfsRepository;
  late MockUserRepository mockUserRepository;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockMyfsRepository = MockMyfsRepository();
    mockUserRepository = MockUserRepository();
    mockAuthRepository = MockAuthRepository();
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
    test('initial state is correct', () {
      expect(myfsBloc.state.status, equals(MyfsStatus.initial));
    });

    blocTest<MyfsBloc, MyfsState>(
      'emits [loading, error] when LoadMyfs stream emits error',
      build: () {
        when(mockAuthRepository.currentUser).thenReturn(null);
        when(mockMyfsRepository.getMyfs())
            .thenAnswer((_) => Stream.error(Exception('Failed to load MYFs')));
        return myfsBloc;
      },
      act: (bloc) => bloc.add(MyfsSubscriptionRequested()),
      expect: () => [
        isA<MyfsState>().having((s) => s.status, 'status', MyfsStatus.loading),
        isA<MyfsState>().having((s) => s.status, 'status', MyfsStatus.failure),
      ],
    );
  });
}
