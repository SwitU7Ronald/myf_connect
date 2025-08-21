import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import '../../services/auth_service.dart';
import '../../app_router.dart';

class PhoneLoginPage extends StatefulWidget {
  const PhoneLoginPage({super.key});

  @override
  State<PhoneLoginPage> createState() => _PhoneLoginPageState();
}

class _PhoneLoginPageState extends State<PhoneLoginPage> {
  final _phoneCtrl = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;
  bool _isSignup = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _isSignup = (args?['isSignup'] ?? false) as bool;
  }

  Future<void> _sendOtp() async {
    setState(() => _loading = true);
    try {
      await _auth.verifyIndianPhone(
        rawPhone: _phoneCtrl.text,
        verificationCompleted: (_) {
          // Auto-complete might occur on Android; OTP page still handles final state.
        },
        verificationFailed: (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message ?? 'Verification failed')));
        },
        codeSent: (id, token) {
          Navigator.pushNamed(
            context,
            AppRoutes.otpVerify,
            arguments: {
              'verificationId': id,
              'phone': _phoneCtrl.text,
              'isSignup': _isSignup,
            },
          );
        },
        codeAutoRetrievalTimeout: (id) {},
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isSignup ? 'Sign up with Phone' : 'Login with Phone')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppTextField(controller: _phoneCtrl, label: 'Indian phone number', keyboardType: TextInputType.phone),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Send OTP', onPressed: _sendOtp, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
