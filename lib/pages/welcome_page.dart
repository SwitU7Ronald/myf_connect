import 'package:flutter/material.dart';
import '../app_router.dart';
import '../widgets/primary_button.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/app_user.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithGoogle();
      if (cred == null) {
        // User cancelled sign-in
        return;
      }
      final user = cred.user;
      if (user == null) return;

      final userService = UserService();
      final existingUser = await userService.getUser(user.uid);

      if (existingUser == null) {
        // New user, create minimal profile with Google info, navigate to details page
        await userService.createOrUpdateUser(AppUser(
          uid: user.uid,
          phone: user.phoneNumber ?? '',
          firstName: user.displayName?.split(' ').first ?? '',
          lastName: user.displayName?.split(' ').skip(1).join(' ') ?? '',
          permissions: const ['general'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ));
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
      } else {
        if (!existingUser.isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainMenu, (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
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
                  label: 'Sign in with Google',
                  onPressed: _googleSignIn,
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
