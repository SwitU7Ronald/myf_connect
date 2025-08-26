import 'package:flutter/material.dart';
import '../../app/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';

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
    setState(() => _loading = true);
    try {
      // Sign in with Google
      final cred = await _auth.signInWithGoogle();
      if (cred == null || cred.user == null) {
        setState(() => _loading = false);
        return;
      }
      final user = cred.user!;
      // Check Firestore for existing profile
      final existingUser = await _userService.getUser(user.uid);

      if (existingUser == null) {
        // Not in Firestore - show message, then redirect to signup
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Account doesn't exist. Please sign up."),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signupDetails,
            (_) => false,
          );
        }
        setState(() => _loading = false);
        return;
      } else if (!existingUser.isProfileComplete) {
        // Profile incomplete - direct to signup details
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signupDetails,
          (_) => false,
        );
        setState(() => _loading = false);
        return;
      } else {
        // Profile complete - direct to main menu
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainMenu,
          (_) => false,
        );
        setState(() => _loading = false);
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign-in error: $e')));
      }
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
