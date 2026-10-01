part of 'admin_myfs_cubit.dart';

abstract class AdminMyfsState extends Equatable {
  const AdminMyfsState();

  @override
  List<Object> get props => [];
}

class AdminMyfsInitial extends AdminMyfsState {}

class AdminMyfsLoading extends AdminMyfsState {}

class AdminMyfsLoaded extends AdminMyfsState {
  final QuerySnapshot snapshot;

  const AdminMyfsLoaded(this.snapshot);

  @override
  List<Object> get props => [snapshot];
}

class AdminMyfsError extends AdminMyfsState {
  final String message;

  const AdminMyfsError(this.message);

  @override
  List<Object> get props => [message];
}
