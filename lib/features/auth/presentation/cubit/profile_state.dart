part of 'profile_cubit.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfilePermissionsLoading extends ProfileState {}

class ProfilePermissionsLoaded extends ProfileState {
  final List<String> camps;
  final List<String> myfs;

  const ProfilePermissionsLoaded({required this.camps, required this.myfs});

  @override
  List<Object> get props => [camps, myfs];
}

class ProfilePermissionsError extends ProfileState {
  final String message;

  const ProfilePermissionsError(this.message);

  @override
  List<Object> get props => [message];
}
