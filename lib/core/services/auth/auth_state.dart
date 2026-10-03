part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final AppUser appUser;
  final bool isAdmin;

  const AuthAuthenticated(this.user, this.appUser, {this.isAdmin = false});

  @override
  List<Object?> get props => [user, appUser, isAdmin];
}

class AuthNeedsProfileCompletion extends AuthState {
  final User user;
  final bool isNewUser;

  const AuthNeedsProfileCompletion(this.user, this.isNewUser);

  @override
  List<Object?> get props => [user, isNewUser];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
