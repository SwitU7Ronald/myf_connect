import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../models/app_user.dart';
import '../../app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OtpVerifyPage extends StatefulWidget {
  final String verificationId;
  final String phone;
  final bool isSignup;
  const OtpVerifyPage({super.key, required this.verificationId, required this.phone, required this.isSignup});

  @override
  State<OtpVerifyPage> createState() => _OtpVerifyPageState();
}

class _OtpVerifyPageState extends State<OtpVerifyPage> {
  final _otpCtrl = TextEditingController();
  final _auth = AuthService();
  final _users = UserService();
  bool _loading = false;

  Future<void> _confirm() async {
    setState(() => _loading = true);
    try {
      final cred = await _auth.signInWithSmsCode(
        verificationId: widget.verificationId,
        smsCode: _otpCtrl.text,
      );

      final user = cred.user;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sign-in failed')));
        return;
      }

      final existing = await _users.getUser(user.uid);

      if (widget.isSignup) {
        // Signup flow
        if (existing != null) {
          // User already registered, ask to login
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Please login, your account is already registered')));
          // Sign out to prevent auto login as new user
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
              context, AppRoutes.phoneLogin, (_) => false,
              arguments: {'isSignup': false});
          return;
        }
        // Create minimal user record, then navigate to details page
        final appUser = AppUser(
          uid: user.uid,
          phone: user.phoneNumber ?? '',
          permissions: const ['general'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _users.createOrUpdateUser(appUser);
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
      } else {
        // Login flow
        if (existing == null) {
          // Instead of showing error, redirect to details page to complete signup
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
          return;
        }

        if (!existing.isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainMenu, (_) => false);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter OTP')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppTextField(controller: _otpCtrl, label: '6-digit OTP', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Verify', onPressed: _confirm, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}