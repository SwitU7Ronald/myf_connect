part of 'camps_bloc.dart';

abstract class CampsEvent extends Equatable {
  const CampsEvent();

  @override
  List<Object> get props => [];
}

class CampsSubscriptionRequested extends CampsEvent {}

class CampsUserPermissionsUpdated extends CampsEvent {
  final List<String> permissions;

  const CampsUserPermissionsUpdated(this.permissions);

  @override
  List<Object> get props => [permissions];
}
