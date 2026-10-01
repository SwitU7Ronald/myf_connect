import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/admin/data/repositories/admin_repository.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'admin_events_state.dart';

class AdminEventsCubit extends Cubit<AdminEventsState> {
  final AdminRepository _adminRepository;
  StreamSubscription? _subscription;

  AdminEventsCubit({required AdminRepository adminRepository})
    : _adminRepository = adminRepository,
      super(AdminEventsInitial());

  void loadEvents(String collectionType, String parentId) {
    emit(AdminEventsLoading());
    _subscription?.cancel();
    _subscription = _adminRepository
        .getEventsStream(collectionType, parentId)
        .listen(
          (snapshot) {
            emit(AdminEventsLoaded(snapshot));
          },
          onError: (error) {
            emit(AdminEventsError(ErrorHandler.handle(error).message));
          },
        );
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
