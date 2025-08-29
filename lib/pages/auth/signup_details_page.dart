import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import '../../services/user_service.dart';
import '../../services/auth_service.dart';
import '../../models/app_user.dart';
import '../../app/app_router.dart';

class SignupDetailsPage extends StatefulWidget {
  const SignupDetailsPage({super.key});

  @override
  State<SignupDetailsPage> createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _nickname = TextEditingController();
  final _phone = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  final _district = TextEditingController();
  final _church = TextEditingController();

  final _users = UserService();
  final _auth = AuthService();
  bool _loading = false;

  // Helper: Capitalize each word in a string
  static String toTitleCase(String? text) {
    if (text == null || text.isEmpty) return '';
    return text
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1).toLowerCase() : '')
        .join(' ');
  }

  // Apply title case to a text field as user types
  void _capitalizeText(TextEditingController controller, String val) {
    final newValue = toTitleCase(val);
    if (val != newValue) {
      controller.value = controller.value.copyWith(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  // Helper: Extract nickname from Google displayName
  static String? extractNickname(String name) {
    if (name.length < 3) return null;
    final match = RegExp(r'\(([^)]+)\)$').firstMatch(name);
    if (match != null) {
      return toTitleCase(match.group(1));
    }
    return null;
  }

  // Helper: Format phone with +91 prefix
  static String formatPhone(String phone) {
    if (phone.startsWith('+91')) return phone;
    return '+91$phone';
  }

  // Initialize state from Firebase Auth user (if any)
  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      final displayName = user.displayName ?? '';
      if (displayName.isNotEmpty) {
        final parts = displayName.replaceAll(RegExp(r'\s*\([^)]+\)$'), '').trim().split(' ');
        _first.text = parts.isNotEmpty ? toTitleCase(parts.first) : '';
        _last.text = parts.length > 1 ? toTitleCase(parts.sublist(1).join(' ')) : '';
        _nickname.text = extractNickname(displayName) ?? '';
      }
      final phone = user.phoneNumber ?? '';
      _phone.text = phone.startsWith('+91') ? phone.substring(3) : phone;
    }
  }

  Future<void> _submit() async {
    if (_loading) return;

    final user = _auth.currentUser;
    if (user == null) {
      _showSnackBar(context, 'Auth error. Please sign in again.');
      return;
    }

    // Validation
    if (_first.text.trim().isEmpty ||
        _last.text.trim().isEmpty ||
        !_isValidPhone(_phone.text.trim()) ||
        _birthdate == null ||
        _gender == null ||
        _district.text.trim().isEmpty ||
        _church.text.trim().isEmpty) {
      _showSnackBar(
        context,
        'Please fill all fields and enter a valid 10-digit Indian phone number.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final existing = await _users.getUser(user.uid);
      final appUser = AppUser(
        uid: user.uid,
        phone: formatPhone(_phone.text.trim()),
        firstName: toTitleCase(_first.text.trim()),
        lastName: toTitleCase(_last.text.trim()),
        nickname: _nickname.text.trim().isNotEmpty ? _nickname.text.trim() : null,
        birthdate: _birthdate,
        gender: _gender,
        district: toTitleCase(_district.text.trim()),
        church: toTitleCase(_church.text.trim()),
        // DO NOT assign any default permissions
        permissions: existing?.permissions ?? const [],
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _users.createOrUpdateUser(appUser);
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.mainMenu,
            (_) => false,
      );
    } catch (e) {
      _showSnackBar(context, 'Error saving details. Please try again.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  bool _isValidPhone(String s) {
    return s.length == 10 && RegExp(r'^[0-9]+$').hasMatch(s);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _nickname.dispose();
    _phone.dispose();
    _district.dispose();
    _church.dispose();
    super.dispose();
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
                  AppTextField(
                    controller: _first,
                    label: 'First name',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) => _capitalizeText(_first, val),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _last,
                    label: 'Last name',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) => _capitalizeText(_last, val),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _nickname,
                    label: 'Nickname (Optional)',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text('+91'),
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
                            hintText: '10-digit number',
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
                              initialDate: DateTime(now.year - 18),
                            );
                            if (picked != null && mounted) {
                              setState(() => _birthdate = picked);
                            }
                          },
                          child: Text(
                            _birthdate == null
                                ? 'Birthdate'
                                : _birthdate!.toIso8601String().split('T').first,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: _gender,
                          items: const [
                            DropdownMenuItem(value: 'Male', child: Text('Male')),
                            DropdownMenuItem(value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                          decoration: const InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _district,
                    label: 'District',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) => _capitalizeText(_district, val),
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    controller: _church,
                    label: 'Church',
                    textCapitalization: TextCapitalization.words,
                    onChanged: (val) => _capitalizeText(_church, val),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Submit',
                    onPressed: _submit,
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
