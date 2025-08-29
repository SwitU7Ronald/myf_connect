import 'package:flutter/material.dart';
import '../../app/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _auth = AuthService();
  bool _loading = false;
  final _userService = UserService();

  Future<void> _googleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      // Sign in with Google
      final cred = await _auth.signInWithGoogle();
      if (!mounted) {
        return; // guard State.context and setState after await
      }
      if (cred == null || cred.user == null) {
        setState(() => _loading = false);
        return;
      }

      final user = cred.user!;
      // Check Firestore for existing profile
      final existingUser = await _userService.getUser(user.uid);
      if (!mounted) {
        return; // guard before using State.context again
      }

      if (existingUser == null) {
        // Not in Firestore - message, then redirect to signup
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account doesn't exist. Please sign up."),
          ),
        );
        setState(() => _loading = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signupDetails,
          (_) => false,
        );
        return;
      }

      if (!existingUser.isProfileComplete) {
        setState(() => _loading = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signupDetails,
          (_) => false,
        );
        return;
      }

      // Profile complete - main menu
      setState(() => _loading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainMenu,
        (_) => false,
      );
    } catch (e) {
      if (!mounted) {
        return; // widget might have been disposed during awaits
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Sign-in error: $e')));
      setState(() => _loading = false);
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
                  label: _loading ? 'Signing in...' : 'Sign in with Google',
                  onPressed: _loading ? () {} : _googleSignIn,
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
