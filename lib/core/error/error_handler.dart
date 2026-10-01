import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/core/error/failures.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return const PermissionFailure();
        case 'unavailable':
        case 'network-request-failed':
          return const NetworkFailure();
        default:
          return ServerFailure(error.message ?? 'Unknown Firebase Error');
      }
    } else if (error is FirebaseAuthException) {
      return AuthFailure(error.message ?? 'Authentication Error');
    }
    return ServerFailure(error.toString());
  }
}
