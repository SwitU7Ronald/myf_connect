part of 'myfs_bloc.dart';

abstract class MyfsEvent extends Equatable {
  const MyfsEvent();

  @override
  List<Object> get props => [];
}

class MyfsSubscriptionRequested extends MyfsEvent {}

class MyfsUserPermissionsUpdated extends MyfsEvent {
  final List<String> permissions;

  const MyfsUserPermissionsUpdated(this.permissions);

  @override
  List<Object> get props => [permissions];
}
