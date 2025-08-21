import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<void> signOut() => _auth.signOut();

  Future<void> verifyIndianPhone({
    required String rawPhone,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(FirebaseAuthException e) verificationFailed,
    required Function(PhoneAuthCredential cred) verificationCompleted,
    required Function(String verificationId) codeAutoRetrievalTimeout,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final digits = rawPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final phone = digits.startsWith('91') && !rawPhone.startsWith('+')
        ? '+$digits'
        : (rawPhone.startsWith('+91') ? rawPhone : '+91$digits');

    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      timeout: timeout,
      verificationCompleted: (cred) => verificationCompleted(cred),
      verificationFailed: (e) => verificationFailed(e),
      codeSent: (id, token) => codeSent(id, token),
      codeAutoRetrievalTimeout: (id) => codeAutoRetrievalTimeout(id),
    );
  }

  Future<UserCredential> signInWithSmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    final cred = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return _auth.signInWithCredential(cred);
  }
}
