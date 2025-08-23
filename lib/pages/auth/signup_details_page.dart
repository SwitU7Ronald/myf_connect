import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _nickname = TextEditingController(); // Will hold nickname silently
  final _phone = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  final _district = TextEditingController();
  final _church = TextEditingController();

  final _users = UserService();
  final _auth = AuthService();
  bool _loading = false;

  String toTitleCase(String text) {
    if (text.isEmpty) return '';
    return text.split(' ').map((word) {
      if (word.isEmpty) return '';
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  void _capitalizeText(TextEditingController controller, String val) {
    final newValue = toTitleCase(val);
    if (val != newValue) {
      controller.value = controller.value.copyWith(
        text: newValue,
        selection: TextSelection.collapsed(offset: newValue.length),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    final user = _auth.currentUser;
    if (user != null) {
      final displayName = user.displayName ?? '';
      if (displayName.isNotEmpty) {
        final nicknameRegex = RegExp(r'\(([^)]+)\)$');
        final nicknameMatch = nicknameRegex.firstMatch(displayName);
        String nickname = '';
        String nameWithoutNickname = displayName;
        if (nicknameMatch != null) {
          nickname = nicknameMatch.group(1)!;
          nameWithoutNickname = displayName.replaceAll(nicknameMatch.group(0)!, '').trim();
        }
        final parts = nameWithoutNickname.split(' ');
        _first.text = parts.isNotEmpty ? toTitleCase(parts.first) : '';
        _last.text = parts.length > 1 ? toTitleCase(parts.sublist(1).join(' ')) : '';
        _nickname.text = toTitleCase(nickname); // stores silently, no UI
      }
      final phone = user.phoneNumber ?? '';
      if (phone.startsWith('+91')) {
        _phone.text = phone.substring(3);
      } else {
        _phone.text = phone;
      }
    }
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1).toLowerCase();
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
        _phone.text.trim().length != 10 ||
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
        phone: '+91${_phone.text.trim()}',
        firstName: capitalize(_first.text.trim()),
        lastName: capitalize(_last.text.trim()),
        nickname: _nickname.text.trim().isEmpty ? null : _nickname.text.trim(),
        birthdate: _birthdate,
        gender: _gender,
        district: capitalize(_district.text.trim()),
        church: capitalize(_church.text.trim()),
        permissions: existing?.permissions ?? const ['general'],
        createdAt: existing?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _users.createOrUpdateUser(appUser);
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, AppRoutes.mainMenu, (_) => false);
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
                  // Nickname input removed intentionally
                  const SizedBox(height: 12),
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
                          ],
                          onChanged: (v) => setState(() => _gender = v),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(), labelText: 'Gender'),
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
                    onPressed: _loading ? () {} : () => _submit(),
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
