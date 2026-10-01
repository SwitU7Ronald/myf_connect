import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:mockito/mockito.dart';
import 'package:myf_connect/features/admin/presentation/cubit/admin_camps_cubit.dart';
import '../../../../helpers/test_helpers.mocks.dart';

void main() {
  late AdminCampsCubit adminCampsCubit;
  late MockAdminRepository mockAdminRepository;

  setUp(() {
    mockAdminRepository = MockAdminRepository();
    
    // Provide a default empty stream to avoid exceptions when Cubit calls loadCamps() in constructor
    when(mockAdminRepository.getCampsStream())
        .thenAnswer((_) => const Stream.empty());
        
    adminCampsCubit = AdminCampsCubit(adminRepository: mockAdminRepository);
  });

  tearDown(() {
    adminCampsCubit.close();
  });

  group('AdminCampsCubit', () {
    test('initial state is correct', () {
      expect(adminCampsCubit.state, isA<AdminCampsLoading>());
    });

    blocTest<AdminCampsCubit, AdminCampsState>(
      'emits [AdminCampsLoading, AdminCampsError] when repository throws error',
      build: () {
        when(mockAdminRepository.getCampsStream())
            .thenAnswer((_) => Stream.error(Exception('Network Error')));
        return AdminCampsCubit(adminRepository: mockAdminRepository);
      },
      expect: () => [
        isA<AdminCampsError>(),
      ],
    );
  });
}
