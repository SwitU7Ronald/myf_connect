import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  final UserRepository userRepository;

  AuthBloc({required this.authRepository, required this.userRepository})
    : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthDeleteAccountRequested>(_onAuthDeleteAccountRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = authRepository.currentUser;
      if (user == null) {
        emit(AuthUnauthenticated());
        return;
      }

      // Fetch real user data from Firestore
      final appUser = await userRepository.getUser(user.uid);

      if (appUser == null || !appUser.isProfileComplete) {
        emit(AuthNeedsProfileCompletion(user, appUser == null));
        return;
      }

      // Check admin status from Firebase custom claims
      final isAdmin = await _checkAdminClaim(user);

      emit(AuthAuthenticated(user, appUser, isAdmin: isAdmin));
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final result = await authRepository.signInWithGoogle();

      switch (result.status) {
        case AuthStatus.success:
          final isAdmin = await _checkAdminClaim(result.user!);
          emit(
            AuthAuthenticated(result.user!, result.appUser!, isAdmin: isAdmin),
          );
          break;
        case AuthStatus.needsProfileCompletion:
          emit(AuthNeedsProfileCompletion(result.user!, result.isNewUser));
          break;
        case AuthStatus.cancelled:
          emit(AuthUnauthenticated());
          break;
        case AuthStatus.error:
          emit(AuthError(result.error ?? 'Unknown error'));
          emit(AuthUnauthenticated());
          break;
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthDeleteAccountRequested(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.deleteIncompleteAccount();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError('Failed to delete account: $e'));
      emit(AuthUnauthenticated());
    }
  }

  /// Checks if the user has an admin custom claim.
  Future<bool> _checkAdminClaim(User user) async {
    try {
      final idTokenResult = await user.getIdTokenResult(true);
      return idTokenResult.claims?['admin'] == true;
    } catch (e) {
      return false;
    }
  }
}
