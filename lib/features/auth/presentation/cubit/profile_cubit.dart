import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/auth/data/repositories/profile_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit({required ProfileRepository profileRepository})
    : _profileRepository = profileRepository,
      super(ProfileInitial());

  Future<void> loadOrganizedPermissions(List<String> permissionIds) async {
    if (permissionIds.isEmpty) {
      emit(const ProfilePermissionsLoaded(camps: [], myfs: []));
      return;
    }

    emit(ProfilePermissionsLoading());

    try {
      final results = await _profileRepository.fetchPermissionTitles(
        permissionIds,
      );
      emit(
        ProfilePermissionsLoaded(
          camps: results['camps'] ?? [],
          myfs: results['myfs'] ?? [],
        ),
      );
    } catch (e) {
      emit(ProfilePermissionsError(e.toString()));
    }
  }
}
