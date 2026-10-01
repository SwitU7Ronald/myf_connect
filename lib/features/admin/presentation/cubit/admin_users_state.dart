part of 'admin_users_cubit.dart';

abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final QuerySnapshot snapshot;

  const AdminUsersLoaded(this.snapshot);

  @override
  List<Object> get props => [snapshot];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError(this.message);

  @override
  List<Object> get props => [message];
}
