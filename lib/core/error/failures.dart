import 'package:equatable/equatable.dart';

/// Base Failure class to map Exceptions to presentation-friendly objects
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Error. Please try again.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication Error.']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Permission Denied.']);
}
