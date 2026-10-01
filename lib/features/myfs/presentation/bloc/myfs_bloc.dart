import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:myf_connect/features/myfs/data/models/myf.dart';
import 'package:myf_connect/features/myfs/data/repositories/myfs_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';

import 'dart:async';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/core/error/error_handler.dart';

part 'myfs_event.dart';
part 'myfs_state.dart';

class MyfsBloc extends Bloc<MyfsEvent, MyfsState> {
  final MyfsRepository _myfsRepository;
  final UserRepository _userRepository;
  final AuthRepository _authRepository;
  StreamSubscription<AppUser?>? _userSubscription;

  MyfsBloc({
    required MyfsRepository myfsRepository,
    required UserRepository userRepository,
    required AuthRepository authRepository,
  }) : _myfsRepository = myfsRepository,
       _userRepository = userRepository,
       _authRepository = authRepository,
       super(const MyfsState()) {
    on<MyfsSubscriptionRequested>(_onSubscriptionRequested);
    on<MyfsUserPermissionsUpdated>(_onPermissionsUpdated);
  }

  void _onPermissionsUpdated(
    MyfsUserPermissionsUpdated event,
    Emitter<MyfsState> emit,
  ) {
    emit(state.copyWith(userPermissions: event.permissions));
  }

  Future<void> _onSubscriptionRequested(
    MyfsSubscriptionRequested event,
    Emitter<MyfsState> emit,
  ) async {
    emit(state.copyWith(status: MyfsStatus.loading));

    try {
      final user = _authRepository.currentUser;
      if (user != null) {
        await _userSubscription?.cancel();
        _userSubscription = _userRepository.getUserStream(user.uid).listen((
          appUser,
        ) {
          add(MyfsUserPermissionsUpdated(appUser?.permissions ?? []));
        });
      }

      await emit.forEach<List<Myf>>(
        _myfsRepository.getMyfs(),
        onData: (myfs) =>
            state.copyWith(status: MyfsStatus.success, myfs: myfs),
        onError: (error, stackTrace) => state.copyWith(
          status: MyfsStatus.failure,
          errorMessage: ErrorHandler.handle(error).message,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(status: MyfsStatus.failure, errorMessage: e.toString()),
      );
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
