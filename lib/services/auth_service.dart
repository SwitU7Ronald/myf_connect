import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/app_user.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final UserService _userService = UserService();
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;
  Future<AuthResult> signInWithGoogle({
    bool forceAccountChooser = false,
  }) async {
    try {
      if (forceAccountChooser) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
      }
      if (_googleSignIn.currentUser != null) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
      }
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return AuthResult.cancelled();
      }
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;
      final existingUser = await _userService.getUser(user.uid);
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (existingUser == null || !existingUser.isProfileComplete) {
        return AuthResult.needsProfileCompletion(user, isNewUser);
      }
      return AuthResult.success(user, existingUser);
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  Future<void> deleteIncompleteAccount() async {
    final user = _auth.currentUser;
    if (user != null) {
      try {
        if (await _googleSignIn.isSignedIn()) {
          await _googleSignIn.disconnect();
          await _googleSignIn.signOut();
        }
        await user.delete();
      } catch (e) {
        debugPrint('Error deleting incomplete account: $e');
        await signOut();
      }
    }
  }

  Future<void> signOut() async {
    try {
      try {
        await _googleSignIn.disconnect();
      } catch (_) {}
      await _googleSignIn.signOut();
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
