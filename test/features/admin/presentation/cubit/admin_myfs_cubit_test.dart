import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_myfs_cubit.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AdminMyfsCubit adminMyfsCubit;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    when(
      mockAdminRepository.getMyfsStream(),
    ).thenAnswer((_) => const Stream.empty());
    adminMyfsCubit = AdminMyfsCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    adminMyfsCubit.close();
  });

  group('AdminMyfsCubit', () {
    test('initial state is AdminMyfsLoading', () {
      expect(adminMyfsCubit.state, isA<AdminMyfsLoading>());
    });

    blocTest<AdminMyfsCubit, AdminMyfsState>(
      'emits [AdminMyfsError] when repository stream emits an error',
      build: () {
        when(
          mockAdminRepository.getMyfsStream(),
        ).thenAnswer((_) => Stream.error(Exception('Network Error')));
        return AdminMyfsCubit(adminRepository: mockAdminRepository);
      },
      expect: () => [isA<AdminMyfsError>()],
    );

    test(
      'state remains AdminMyfsLoading when loadMyfs is called while already loading',
      () {
        when(
          mockAdminRepository.getMyfsStream(),
        ).thenAnswer((_) => const Stream.empty());
        final cubit = AdminMyfsCubit(adminRepository: mockAdminRepository);
        cubit.loadMyfs();
        // Already in loading state — calling again should not change it
        expect(cubit.state, isA<AdminMyfsLoading>());
        cubit.close();
      },
    );
  });
}
