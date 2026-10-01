import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'admin_camps_state.dart';

class AdminCampsCubit extends Cubit<AdminCampsState> {
  final AdminRepository _adminRepository;
  StreamSubscription? _subscription;

  AdminCampsCubit({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminCampsInitial()) {
    loadCamps();
  }

  void loadCamps() {
    emit(AdminCampsLoading());
    _subscription?.cancel();
    _subscription = _adminRepository.getCampsStream().listen(
      (snapshot) {
        emit(AdminCampsLoaded(snapshot));
      },
      onError: (error) {
        emit(AdminCampsError(ErrorHandler.handle(error).message));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
