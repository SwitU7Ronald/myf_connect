part of 'admin_camps_cubit.dart';

abstract class AdminCampsState extends Equatable {
  const AdminCampsState();

  @override
  List<Object> get props => [];
}

class AdminCampsInitial extends AdminCampsState {}

class AdminCampsLoading extends AdminCampsState {}

class AdminCampsLoaded extends AdminCampsState {
  final QuerySnapshot snapshot;

  const AdminCampsLoaded(this.snapshot);

  @override
  List<Object> get props => [snapshot];
}

class AdminCampsError extends AdminCampsState {
  final String message;

  const AdminCampsError(this.message);

  @override
  List<Object> get props => [message];
}
