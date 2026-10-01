import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/camps/data/models/camp.dart';
import 'package:myf_connect/features/camps/data/repositories/camps_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';

import 'dart:async';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'camps_event.dart';
part 'camps_state.dart';

/// [CampsBloc] is responsible for managing the state of the camps list feature.
/// It listens to real-time updates from [CampsRepository] and handles user permissions
/// by continuously listening to the [UserRepository].
class CampsBloc extends Bloc<CampsEvent, CampsState> {
  final CampsRepository _campsRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _userSubscription;

  /// Creates a [CampsBloc] with the required dependencies.
  ///
  /// The [_campsRepository] is used to fetch the stream of camps.
  /// The [_userRepository] and [_authRepository] are used to track the current user's permissions.
  CampsBloc({
    required CampsRepository campsRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _campsRepository = campsRepository,
       _userRepository = userRepository,
       _authRepository = authRepository,
       super(const CampsState()) {
    on<CampsSubscriptionRequested>(_onSubscriptionRequested);
    on<CampsUserPermissionsUpdated>(_onPermissionsUpdated);
  }

  void _onPermissionsUpdated(
    CampsUserPermissionsUpdated event,
    Emitter<CampsState> emit,
  ) {
    emit(state.copyWith(userPermissions: event.permissions));
  }

  Future<void> _onSubscriptionRequested(
    CampsSubscriptionRequested event,
    Emitter<CampsState> emit,
  ) async {
    emit(state.copyWith(status: CampsStatus.loading));

    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await _userSubscription?.cancel();
        _userSubscription = _userRepository.getUserStream(user.uid).listen((
          appUser,
        ) {
          add(CampsUserPermissionsUpdated(appUser?.permissions ?? []));
        });
      }

      await emit.forEach<List<Camp>>(
        _campsRepository.getCamps(),
        onData: (camps) =>
            state.copyWith(status: CampsStatus.success, camps: camps),
        onError: (error, stackTrace) => state.copyWith(
          status: CampsStatus.failure,
          errorMessage: ErrorHandler.handle(error).message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: CampsStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
