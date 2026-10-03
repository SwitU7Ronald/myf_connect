import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'admin_users_state.dart';

class AdminUsersCubit extends Cubit<AdminUsersState> {
  final AdminRepository _adminRepository;
  StreamSubscription<QuerySnapshot>? _subscription;

  AdminUsersCubit({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminUsersInitial()) {
    loadUsers();
  }

  void loadUsers() {
    emit(AdminUsersLoading());
    _subscription?.cancel();
    _subscription = _adminRepository.getUsersStream().listen(
      (snapshot) {
        emit(AdminUsersLoaded(snapshot));
      },
      onError: (Object error) {
        emit(AdminUsersError(ErrorHandler.handle(error).message));
      },
    );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
