import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widgets.dart';
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

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null ||
        value.trim().length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(value.trim())) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;
    if (!_formKey.currentState!.validate()) return;
    if (_birthdate == null) {
      context.showErrorSnackBar('Please select your birthdate');
      return;
    }
    if (_gender == null) {
      context.showErrorSnackBar('Please select gender');
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      context.showErrorSnackBar('Authentication error. Please restart app.');
      return;
    }

    setState(() => _loading = true);

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
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.mainMenu,
              (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error saving profile: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complete Your Profile')),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Saving profile...',
        child: SingleChildScrollView(
          padding: MethodistTheme.paddingL,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'First Name'),
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'Last Name'),
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _nicknameCtrl,
                  label: 'Nickname (Optional)',
                  textCapitalization: TextCapitalization.words,
                ),

                SizedBox(height: context.spacingM),

                PhoneTextField(
                  controller: _phoneCtrl,
                  validator: _validatePhone,
                ),

                SizedBox(height: context.spacingM),

                DatePickerField(
                  selectedDate: _birthdate,
                  label: 'Birthdate',
                  hint: 'Select your birthdate',
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onDateSelected: (date) => setState(() => _birthdate = date),
                ),

                SizedBox(height: context.spacingM),

                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                  ),
                  validator: (v) => v == null ? 'Select gender' : null,
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _districtCtrl,
                  label: 'District',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'District'),
                ),

                SizedBox(height: context.spacingM),

                AppTextField(
                  controller: _churchCtrl,
                  label: 'Church',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'Church'),
                ),

                SizedBox(height: context.spacingXL),

                PrimaryButton(
                  label: 'Submit',
                  onPressed: _submit,
                  loading: _loading,
                  fullWidth: true,
                  icon: Icons.check,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}