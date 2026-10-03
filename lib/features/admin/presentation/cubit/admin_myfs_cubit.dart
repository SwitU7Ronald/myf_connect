import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'admin_myfs_state.dart';

class AdminMyfsCubit extends Cubit<AdminMyfsState> {
  final AdminRepository _adminRepository;
  StreamSubscription<QuerySnapshot>? _subscription;

  AdminMyfsCubit({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminMyfsInitial()) {
    loadMyfs();
  }

  void loadMyfs() {
    emit(AdminMyfsLoading());
    _subscription?.cancel();
    _subscription = _adminRepository.getMyfsStream().listen(
      (snapshot) {
        emit(AdminMyfsLoaded(snapshot));
      },
      onError: (Object error) {
        emit(AdminMyfsError(ErrorHandler.handle(error).message));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
