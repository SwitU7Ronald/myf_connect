part of 'admin_events_cubit.dart';

abstract class AdminEventsState extends Equatable {
  const AdminEventsState();

  @override
  List<Object> get props => [];
}

class AdminEventsInitial extends AdminEventsState {}

class AdminEventsLoading extends AdminEventsState {}

class AdminEventsLoaded extends AdminEventsState {
  final QuerySnapshot snapshot;

  const AdminEventsLoaded(this.snapshot);

  @override
  List<Object> get props => [snapshot];
}

class AdminEventsError extends AdminEventsState {
  final String message;

  const AdminEventsError(this.message);

  @override
  List<Object> get props => [message];
}
