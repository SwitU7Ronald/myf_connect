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
  final _phone = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  final _district = TextEditingController();
  final _church = TextEditingController();

  final _users = UserService();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      final displayName = user.displayName ?? '';
      if (displayName.isNotEmpty) {
        final parts = displayName.split(' ');
        _first.text = parts.isNotEmpty ? parts.first : '';
        _last.text = parts.length > 1 ? parts.sublist(1).join(' ') : '';
      }
      _phone.text = user.phoneNumber ?? '';
    }
  }

  Future<void> _submit() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Auth error. Please sign in again.')));
      return;
    }

    if (_first.text.trim().isEmpty ||
        _last.text.trim().isEmpty ||
        _phone.text.trim().isEmpty ||
        _birthdate == null ||
        _gender == null ||
        _district.text.trim().isEmpty ||
        _church.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);
    try {
      final existing = await _users.getUser(user.uid);
      final appUser = AppUser(
        uid: user.uid,
        phone: _phone.text.trim(),
        firstName: _first.text.trim(),
        lastName: _last.text.trim(),
        birthdate: _birthdate,
        gender: _gender,
        district: _district.text.trim(),
        church: _church.text.trim(),
        permissions: existing?.permissions ?? const ['general'],
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _users.createOrUpdateUser(appUser);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainMenu,
              (_) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving details: $e')),
      );
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
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppTextField(controller: _first, label: 'First name'),
                  const SizedBox(height: 12),
                  AppTextField(controller: _last, label: 'Last name'),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _phone,
                    label: 'Phone number',
                    keyboardType: TextInputType.phone,
                  ),
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
                              initialDate:
                              DateTime(now.year - 18, now.month, now.day),
                            );
                            if (picked != null) setState(() => _birthdate = picked);
                          },
                          child: Text(_birthdate == null
                              ? 'Birthdate'
                              : _birthdate!.toIso8601String().split('T').first),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'Female', child: Text('Female')),
                            DropdownMenuItem(value: 'Other', child: Text('Other')),
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: 'Gender'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(controller: _district, label: 'District'),
                  const SizedBox(height: 12),
                  AppTextField(controller: _church, label: 'Church'),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Submit',
                    onPressed: _loading ? () {} : () { _submit(); },  // provide empty function to disable
                    loading: _loading,
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
