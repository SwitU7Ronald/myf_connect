import 'package:flutter/material.dart';
import '../../app/app_router.dart';

class CreditPage extends StatelessWidget {
  const CreditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline, size: 80, color: Colors.red),
                const SizedBox(height: 20),
                const Text(
                  'Methodist Connect\nGujarat Methodist Camps & MYF',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'General permission by default. Admins manage users, camps, events, and MYF.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: () {
                    // Replace CreditPage with WelcomePage inside the unauth navigator
                    Navigator.pushReplacementNamed(context, AppRoutes.welcome);
                  },
                  child: const Text('Continue'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
