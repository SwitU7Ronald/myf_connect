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
      MethodistTheme.showErrorSnackBar(context, 'Please select your birthdate');
      return;
    }
    if (_gender == null) {
      MethodistTheme.showErrorSnackBar(context, 'Please select gender');
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      MethodistTheme.showErrorSnackBar(context, 'Authentication error. Please restart app.');
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
        MethodistTheme.showErrorSnackBar(context, 'Error saving profile: $e');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MethodistTheme.lightGray,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        backgroundColor: MethodistTheme.primaryRed,
        foregroundColor: MethodistTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Saving profile...',
        child: SingleChildScrollView(
          padding: MethodistTheme.paddingL,
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header Card
                MethodistCard(
                  child: Column(
                    children: [
                      Container(
                        padding: MethodistTheme.paddingM,
                        decoration: BoxDecoration(
                          color: MethodistTheme.primaryRed.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusXL),
                        ),
                        child: Icon(
                          Icons.person_add,
                          size: 48,
                          color: MethodistTheme.primaryRed,
                        ),
                      ),
                      SizedBox(height: MethodistTheme.spacingM),
                      Text(
                        'Complete Your Profile',
                        style: MethodistTheme.headlineSmall,
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: MethodistTheme.spacingS),
                      Text(
                        'Please fill in your details to continue',
                        style: MethodistTheme.bodyMedium.copyWith(
                          color: MethodistTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MethodistTheme.spacingL),

                AppTextField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'First Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'Last Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _nicknameCtrl,
                  label: 'Nickname (Optional)',
                  textCapitalization: TextCapitalization.words,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                PhoneTextField(
                  controller: _phoneCtrl,
                  validator: _validatePhone,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                DatePickerField(
                  selectedDate: _birthdate,
                  label: 'Birthdate',
                  hint: 'Select your birthdate',
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  onDateSelected: (date) => setState(() => _birthdate = date),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                    ),
                  ),
                  validator: (v) => v == null ? 'Select gender' : null,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _districtCtrl,
                  label: 'District',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'District'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                AppTextField(
                  controller: _churchCtrl,
                  label: 'Church',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'Church'),
                ),

                SizedBox(height: MethodistTheme.spacingXL),

                PrimaryButton(
                  label: 'Complete Profile',
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