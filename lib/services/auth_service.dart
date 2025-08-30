import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  );

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UserCredential?> signInWithGoogle({bool forceAccountChooser = false}) async {
    try {
      if (forceAccountChooser) {
        try {
          await _googleSignIn.disconnect(); // revoke to avoid silent reuse
        } catch (_) {}
        await _googleSignIn.signOut();
      }

      // Clear any cached account if present
      if (_googleSignIn.currentUser != null) {
        try {
          await _googleSignIn.disconnect();
        } catch (_) {}
        await _googleSignIn.signOut();
      }

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Returns UserCredential with additionalUserInfo.isNewUser available
      return await _auth.signInWithCredential(credential);
    } catch (e) {
      rethrow;
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
