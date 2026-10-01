import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_users_cubit.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AdminUsersCubit adminUsersCubit;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    when(mockAdminRepository.getUsersStream())
        .thenAnswer((_) => const Stream.empty());
    adminUsersCubit = AdminUsersCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    adminUsersCubit.close();
  });

  group('AdminUsersCubit', () {
    test('initial state is AdminUsersLoading', () {
      expect(adminUsersCubit.state, isA<AdminUsersLoading>());
    });

    blocTest<AdminUsersCubit, AdminUsersState>(
      'emits [AdminUsersError] when repository stream emits an error',
      build: () {
        when(mockAdminRepository.getUsersStream())
            .thenAnswer((_) => Stream.error(Exception('Firestore Error')));
        return AdminUsersCubit(adminRepository: mockAdminRepository);
      },
      expect: () => [
        isA<AdminUsersError>(),
      ],
    );

    test(
      'state remains AdminUsersLoading when loadUsers is called while already loading',
      () {
        when(mockAdminRepository.getUsersStream())
            .thenAnswer((_) => const Stream.empty());
        final cubit = AdminUsersCubit(adminRepository: mockAdminRepository);
        cubit.loadUsers();
        // Already in loading state — calling again should not change it
        expect(cubit.state, isA<AdminUsersLoading>());
        cubit.close();
      },
    );
  });
}
