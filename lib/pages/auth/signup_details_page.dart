import 'package:flutter/material.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/app_user.dart';
import '../../app_router.dart';

class SignupDetailsPage extends StatefulWidget {
  const SignupDetailsPage({super.key});

  @override
  State<SignupDetailsPage> createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  final _state = TextEditingController();
  final _city = TextEditingController();

  final _users = UserService();
  final _auth = AuthService();
  bool _loading = false;

  Future<void> _submit() async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (_first.text.trim().isEmpty ||
        _last.text.trim().isEmpty ||
        _birthdate == null ||
        _gender == null ||
        _state.text.trim().isEmpty ||
        _city.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);
    try {
      final existing = await _users.getUser(user.uid);
      final appUser = AppUser(
        uid: user.uid,
        phone: user.phoneNumber ?? '',
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        birthdate: _birthdate,
        gender: _gender,
        state: _state.text.trim(),
        city: _city.text.trim(),
        permissions: existing?.permissions ?? const ['general'],
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _users.createOrUpdateUser(appUser);
      // After saving full profile, navigate to main menu
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainMenu, (_) => false);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Details')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AppTextField(controller: _first, label: 'First name'),
                const SizedBox(height: 12),
                AppTextField(controller: _last, label: 'Last name'),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final picked = await showDatePicker(
                            context: context,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(now.year, now.month, now.day),
                            initialDate: DateTime(now.year - 18, now.month, now.day),
                          );
                          if (picked != null) setState(() => _birthdate = picked);
                        },
                        child: Text(_birthdate == null ? 'Birthdate' : _birthdate!.toString().split(' ').first),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _gender,
                        items: const [
                          DropdownMenuItem(value: 'Male', child: Text('Male')),
                          DropdownMenuItem(value: 'Female', child: Text('Female')),
                          DropdownMenuItem(value: 'Other', child: Text('Other')),
                        ],
                        onChanged: (v) => setState(() => _gender = v),
                        decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Gender'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                AppTextField(controller: _state, label: 'State'),
                const SizedBox(height: 12),
                AppTextField(controller: _city, label: 'City'),
                const SizedBox(height: 16),
                PrimaryButton(label: 'Submit', onPressed: _submit, loading: _loading),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
