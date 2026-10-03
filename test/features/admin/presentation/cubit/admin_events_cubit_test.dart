import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_events_cubit.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AdminEventsCubit adminEventsCubit;
  late MockAdminRepository mockAdminRepository;

  const collectionType = 'camps';
  const parentId = 'camp-001';

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    adminEventsCubit = AdminEventsCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    adminEventsCubit.close();
  });

  group('AdminEventsCubit', () {
    test('initial state is AdminEventsInitial', () {
      expect(adminEventsCubit.state, isA<AdminEventsInitial>());
    });

    blocTest<AdminEventsCubit, AdminEventsState>(
      'emits [AdminEventsLoading] then stops when stream is empty',
      build: () => AdminEventsCubit(adminRepository: mockAdminRepository),
      act: (cubit) {
        when(
          mockAdminRepository.getEventsStream(collectionType, parentId),
        ).thenAnswer((_) => const Stream.empty());
        cubit.loadEvents(collectionType, parentId);
      },
      expect: () => [isA<AdminEventsLoading>()],
    );

    blocTest<AdminEventsCubit, AdminEventsState>(
      'emits [AdminEventsLoading, AdminEventsError] when repository throws',
      build: () {
        when(
          mockAdminRepository.getEventsStream(collectionType, parentId),
        ).thenAnswer((_) => Stream.error(Exception('Permission denied')));
        return AdminEventsCubit(adminRepository: mockAdminRepository);
      },
      act: (cubit) => cubit.loadEvents(collectionType, parentId),
      expect: () => [isA<AdminEventsLoading>(), isA<AdminEventsError>()],
    );
  });
}
