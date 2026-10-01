import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/camps/data/repositories/camps_repository.dart';
import 'package:myf_connect/features/myfs/data/repositories/myfs_repository.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final CampsRepository _campsRepository;
  final MyfsRepository _myfsRepository;

  ProfileCubit({
    required CampsRepository campsRepository,
    required MyfsRepository myfsRepository,
  }) : _campsRepository = campsRepository,
       _myfsRepository = myfsRepository,
       super(ProfileInitial());

  Future<void> loadOrganizedPermissions(List<String> permissionIds) async {
    if (permissionIds.isEmpty) {
      emit(const ProfilePermissionsLoaded(camps: [], myfs: []));
      return;
    }

    emit(ProfilePermissionsLoading());

    try {
      final campTitles = <String>[];
      final myfTitles = <String>[];

      final campsList = await _campsRepository.getCamps().first;
      final myfsList = await _myfsRepository.getMyfs().first;

      final campMap = {for (var camp in campsList) camp.id: camp.title};
      final myfMap = {for (var myf in myfsList) myf.id: myf.title};

      for (final permId in permissionIds) {
        if (campMap.containsKey(permId)) {
          campTitles.add(campMap[permId]!);
        } else if (myfMap.containsKey(permId)) {
          myfTitles.add(myfMap[permId]!);
        }
      }

      campTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      myfTitles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

      emit(ProfilePermissionsLoaded(camps: campTitles, myfs: myfTitles));
    } catch (e) {
      emit(ProfilePermissionsError(e.toString()));
    }
  }
}
