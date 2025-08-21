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
        // If user already exists, ask to login
        if (existing != null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please login, account already registered')));
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainMenu, (_) => false);
          return;
        }
        // First-time signup: create minimal record and go to details
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
        // Login path
        if (existing == null) {
          // No profile: ask to signup first
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please first signup. Your account doesn\'t exist.')));
          // Keep them signed in but navigate to details to complete? Or sign out and go to phone page.
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.phoneLogin, (_) => false, arguments: {'isSignup': true});
          return;
        }
        // If profile incomplete, go to details
        if (!existing.isProfileComplete) {
          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.signupDetails, (_) => false);
          return;
        }
        // Go to main menu
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
