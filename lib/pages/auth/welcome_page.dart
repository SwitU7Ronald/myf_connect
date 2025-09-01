// lib/pages/auth/welcome_page.dart
import 'package:flutter/material.dart';
import '../../app/app_router.dart';
import '../../widgets/primary_button.dart';
import '../../services/auth_service.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _googleSignIn() async {
    if (_loading) return;
    setState(() => _loading = true);

    try {
      final result = await _auth.signInWithGoogle();

      if (!mounted) return;

      switch (result.status) {
        case AuthStatus.success:
        // User has complete profile, go to main menu
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.mainMenu,
                (_) => false,
          );
          break;

        case AuthStatus.needsProfileCompletion:
        // User needs to complete profile
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.signupDetails,
                (_) => false,
          );
          break;

        case AuthStatus.cancelled:
        // User cancelled sign-in, do nothing
          break;

        case AuthStatus.error:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Sign-in error: ${result.error}')),
          );
          break;
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unexpected error: $e')),
      );
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
