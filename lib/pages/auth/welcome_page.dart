import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../app/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../services/user_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});
  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _loading = false;
  Future<void> _continueWithGoogle() async {
    if (_loading) return;
    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        if (mounted) {
          setState(() => _loading = false);
        }
        return;
      }
      final googleAuth = await googleUser.authentication;
      final email = googleUser.email;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user!;
      if (!mounted) return;
      final userService = UserService();
      final appUser = await userService.getUser(firebaseUser.uid);
      if (!mounted) return;
      if (appUser != null && appUser.isProfileComplete) {
        navigator.pushReplacementNamed(AppRoutes.mainMenu);
      } else {
        navigator.pushReplacementNamed(
          AppRoutes.signupDetails,
          arguments: {
            'email': email,
            'displayName': googleUser.displayName ?? '',
            'photoURL': googleUser.photoUrl,
            'isNewUser': appUser == null,
          },
        );
      }
    } catch (e) {
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {}
      if (mounted) {
        messenger.showSnackBar(SnackBar(content: Text('Sign-in error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Welcome to Methodist Connect',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: _loading ? 'Signing in...' : 'Continue with Google',
                  onPressed: _loading ? null : _continueWithGoogle,
                  loading: _loading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
