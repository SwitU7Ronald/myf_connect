import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:myf_connect/core/models/app_user.dart';
import 'package:myf_connect/core/services/users/user_repository.dart';
import 'package:myf_connect/core/config/env_config.dart';

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final UserRepository _userRepository;
  bool _initialized = false;

  AuthRepository({
    FirebaseAuth? firebaseAuth,
    UserRepository? userRepository,
    GoogleSignIn? googleSignIn,
  }) : _auth = firebaseAuth ?? FirebaseAuth.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn.instance,
       _userRepository = userRepository ?? UserRepository();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _googleSignIn.initialize(
        clientId: EnvConfig.googleClientId,
        serverClientId: EnvConfig.googleServerClientId,
      );
      _initialized = true;
    }
  }

  Future<AuthResult> signInWithGoogle({
    bool forceAccountChooser = false,
  }) async {
    try {
      debugPrint('AuthRepo: Starting Google Sign In');
      await _ensureInitialized();
      if (forceAccountChooser) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
      }

      debugPrint('AuthRepo: Calling _googleSignIn.authenticate()');
      final googleUser = await _googleSignIn.authenticate();
      debugPrint(
        'AuthRepo: _googleSignIn.authenticate() returned: ${googleUser.email}',
      );

      debugPrint('AuthRepo: Getting authentication tokens');
      final googleAuth = googleUser.authentication;
      debugPrint(
        'AuthRepo: Tokens received. idToken present: ${googleAuth.idToken != null}',
      );

      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      debugPrint('AuthRepo: Signing in to Firebase with credential');
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      debugPrint('AuthRepo: Firebase sign in successful for: ${user.uid}');

      final existingUser = await _userRepository.getUser(user.uid);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;

      if (existingUser == null || !existingUser.isProfileComplete) {
        debugPrint('AuthRepo: Needs profile completion');
        return AuthResult.needsProfileCompletion(user, isNewUser);
      }
      debugPrint('AuthRepo: Success');
      return AuthResult.success(user, existingUser);
    } catch (e, stack) {
      debugPrint('AuthRepo: Error during sign in: $e\n$stack');
      return AuthResult.error(e.toString());
    }
  }

  Future<void> deleteIncompleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        await _ensureInitialized();
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        try {
          await _googleSignIn.signOut();
        } catch (_) {}
        await user.delete();
      } catch (e) {
        debugPrint('Error deleting incomplete account: $e');
        await signOut();
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _ensureInitialized();
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } finally {
      await _auth.signOut();
    }
  }
}

class AuthResult {
  final AuthStatus status;
  final User? user;
  final AppUser? appUser;
  final bool isNewUser;
  final String? error;
  AuthResult._(
    this.status,
    this.user,
    this.appUser,
    this.isNewUser,
    this.error,
  );
  factory AuthResult.success(User user, AppUser appUser) =>
      AuthResult._(AuthStatus.success, user, appUser, false, null);
  factory AuthResult.needsProfileCompletion(User user, bool isNewUser) =>
      AuthResult._(
        AuthStatus.needsProfileCompletion,
        user,
        null,
        isNewUser,
        null,
      );
  factory AuthResult.cancelled() =>
      AuthResult._(AuthStatus.cancelled, null, null, false, null);
  factory AuthResult.error(String error) =>
      AuthResult._(AuthStatus.error, null, null, false, error);
}

enum AuthStatus { success, needsProfileCompletion, cancelled, error }
