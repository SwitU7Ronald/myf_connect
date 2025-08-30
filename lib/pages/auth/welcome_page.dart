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
      final cred = await _auth.signInWithGoogle(); // must return UserCredential
      if (!mounted) return;

      if (cred == null || cred.user == null) {
        setState(() => _loading = false);
        return;
      }

      final isNew = cred.additionalUserInfo?.isNewUser ?? false; // key gate

      final user = cred.user!;
      final existingUser = await _userService.getUser(user.uid);
      if (!mounted) return;

      final profileComplete = existingUser?.isProfileComplete == true;

      if (isNew || existingUser == null || !profileComplete) {
        setState(() => _loading = false);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.signupDetails,
              (_) => false,
        );
        return;
      }

      setState(() => _loading = false);
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainMenu,
            (_) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in error: $e')),
      );
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
