import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/text_fields.dart';
import '../../app/app_router.dart';

class SignupDetailsPage extends StatefulWidget {
  const SignupDetailsPage({super.key});
  @override
  State<SignupDetailsPage> createState() => _SignupDetailsPageState();
}

class _SignupDetailsPageState extends State<SignupDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _districtCtrl = TextEditingController();
  final _churchCtrl = TextEditingController();
  DateTime? _birthdate;
  String? _gender;
  bool _loading = false;
  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _districtCtrl.dispose();
    _churchCtrl.dispose();
    super.dispose();
  }

  String? _validateNotEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null ||
        value.trim().length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit Indian mobile number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_birthdate == null) {
      _showSnackBar('Please select your birthdate');
      return;
    }
    if (_gender == null) {
      _showSnackBar('Please select gender');
      return;
    }
    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      _showSnackBar('Authentication error. Please restart app.');
      return;
    }
    setState(() => _loading = true);
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);
      await userRef.set({
        'email': firebaseUser.email,
        'phone': '+91${_phoneCtrl.text.trim()}',
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'nickname': _nicknameCtrl.text.trim().isNotEmpty
            ? _nicknameCtrl.text.trim()
            : null,
        'birthdate': Timestamp.fromDate(_birthdate!),
        'gender': _gender,
        'district': _districtCtrl.text.trim(),
        'church': _churchCtrl.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        navigator.pushNamedAndRemoveUntil(AppRoutes.mainMenu, (_) => false);
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text('Error saving profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildBirthdateField() {
    return OutlinedButton(
      onPressed: _loading
          ? null
          : () async {
              final now = DateTime.now();
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime(now.year - 18),
                firstDate: DateTime(1900),
                lastDate: now,
              );
              if (picked != null && mounted) {
                setState(() => _birthdate = picked);
              }
            },
      child: Text(
        _birthdate == null
            ? 'Select Birthdate'
            : _birthdate!.toLocal().toString().split('T').first,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              AppTextField(
                controller: _firstNameCtrl,
                label: 'First Name',
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'First Name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _lastNameCtrl,
                label: 'Last Name',
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Last Name'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _nicknameCtrl,
                label: 'Nickname (Optional)',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 16,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text('+91'),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Mobile Number',
                        border: OutlineInputBorder(),
                        hintText: '10-digit number',
                      ),
                      validator: _validatePhone,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(children: [Expanded(child: _buildBirthdateField())]),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: _loading ? null : (v) => setState(() => _gender = v),
                decoration: const InputDecoration(
                  labelText: 'Gender',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null ? 'Select gender' : null,
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _districtCtrl,
                label: 'District',
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'District'),
              ),
              const SizedBox(height: 12),
              AppTextField(
                controller: _churchCtrl,
                label: 'Church',
                textCapitalization: TextCapitalization.words,
                validator: (v) => _validateNotEmpty(v, 'Church'),
              ),
              const SizedBox(height: 20),
              PrimaryButton(
                label: _loading ? 'Saving...' : 'Submit',
                onPressed: _loading ? null : _submit,
                loading: _loading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
