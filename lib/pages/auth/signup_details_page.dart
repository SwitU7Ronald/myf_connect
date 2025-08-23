import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // <-- add this import
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
      final phone = user.phoneNumber ?? '';
      if (phone.startsWith('+91')) {
        _phone.text = phone.substring(3); // Remove +91 prefix & show only 10 digits
      } else {
        _phone.text = phone;
      }
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
        _phone.text.trim().length != 10 || // additional validation
        _birthdate == null ||
        _gender == null ||
        _district.text.trim().isEmpty ||
        _church.text.trim().isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please fill all fields and enter valid 10-digit phone number')));
      return;
    }

    setState(() => _loading = true);
    try {
      final existing = await _users.getUser(user.uid);
      final appUser = AppUser(
        uid: user.uid,
        phone: '+91${_phone.text.trim()}', // prepend +91 here before save
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

                  // Phone input with fixed +91 prefix and 10-digit input
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          '+91',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _phone,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            border: OutlineInputBorder(),
                            hintText: 'Enter 10-digit number',
                          ),
                        ),
                      ),
                    ],
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
                              initialDate: DateTime(now.year - 18, now.month, now.day),
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
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
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
                    onPressed: _loading ? () {} : () { _submit(); },
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
