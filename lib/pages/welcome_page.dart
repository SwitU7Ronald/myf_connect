import 'package:flutter/material.dart';
import '../app_router.dart';
import '../widgets/primary_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

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
                const Text('Welcome to Methodist Connect', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                const SizedBox(height: 24),
                PrimaryButton(
                  label: 'Login',
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneLogin),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.phoneLogin, arguments: {'isSignup': true}),
                  child: const Text('New user? Sign up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
