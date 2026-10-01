/// Base class for all custom exceptions in the app
abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

/// Thrown when there's an issue communicating with the server/Firebase
class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred.']);
}

/// Thrown when a network request times out or is offline
class NetworkException extends AppException {
  const NetworkException([super.message = 'No internet connection.']);
}

/// Thrown when authentication fails
class AuthException extends AppException {
  const AuthException([super.message = 'Authentication failed.']);
}

/// Thrown when data validation fails locally
class ValidationException extends AppException {
  const ValidationException([super.message = 'Invalid data provided.']);
}

/// Thrown when the user lacks required permissions
class PermissionException extends AppException {
  const PermissionException([
    super.message = 'You do not have permission to perform this action.',
  ]);
}
