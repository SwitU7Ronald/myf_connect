// lib/pages/auth/signup_details_page.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../widgets/widgets.dart';
import '../../models/district_data.dart';
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

  DateTime? _birthdate;
  String? _gender;
  String? _selectedDistrict;
  String? _selectedMyf;
  bool _loading = false;

  // FIXED: Initialize with India as default (matching InternationalPhoneField default)
  CountryData? _selectedCountry = const CountryData(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    minLength: 10,
    maxLength: 10,
  );

  // Check if "Other" district is selected
  bool get _isOtherDistrictSelected => _selectedDistrict == 'Other';

  @override
  void initState() {
    super.initState();
    _autoFillFromArguments();
  }

  void _autoFillFromArguments() {
    // Get the arguments passed from welcome page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      if (args != null) {
        setState(() {
          // Auto-fill from Google account data with proper formatting
          _firstNameCtrl.text = args['firstName'] ?? '';
          _lastNameCtrl.text = args['lastName'] ?? '';
          _nicknameCtrl.text = args['nickname'] ?? '';

          debugPrint('SignupDetailsPage: Auto-filled from Google - First: ${_firstNameCtrl.text}, Last: ${_lastNameCtrl.text}, Nickname: ${_nicknameCtrl.text}');
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String? _validateRequired(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  String? _validateDistrict(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please select your district';
    }
    if (!DistrictData.isValidDistrict(value)) {
      return 'Please select a valid district';
    }
    return null;
  }

  String? _validateMyf(String? value) {
    if (_selectedDistrict == null) return null;

    if (value == null || value.isEmpty) {
      return _isOtherDistrictSelected
          ? 'Please enter your church/MYF'
          : 'Please select your church/MYF';
    }

    if (!_isOtherDistrictSelected &&
        !DistrictData.isValidMyfForDistrict(_selectedDistrict!, value)) {
      return 'Please select a valid church/MYF for your district';
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
    if (_selectedDistrict == null) {
      MethodistTheme.showErrorSnackBar(context, 'Please select your district');
      return;
    }
    if (_selectedMyf == null || _selectedMyf!.isEmpty) {
      MethodistTheme.showErrorSnackBar(context, 'Please ${_isOtherDistrictSelected ? "enter" : "select"} your church/MYF');
      return;
    }
    if (_selectedCountry == null) {
      MethodistTheme.showErrorSnackBar(context, 'Please select country code');
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
        'phone': '${_selectedCountry!.dialCode}${_phoneCtrl.text.trim()}', // Include country code
        'firstName': _firstNameCtrl.text.trim(),
        'lastName': _lastNameCtrl.text.trim(),
        'nickname': _nicknameCtrl.text.trim().isNotEmpty
            ? _nicknameCtrl.text.trim()
            : null,
        'birthdate': Timestamp.fromDate(_birthdate!),
        'gender': _gender,
        'district': _selectedDistrict,
        'church': _selectedMyf,
        'countryCode': _selectedCountry!.code,
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
                        'We\'ve pre-filled some details from your Google account',
                        style: MethodistTheme.bodyMedium.copyWith(
                          color: MethodistTheme.mediumGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MethodistTheme.spacingL),

                // First Name Field - with auto-capitalization
                AppTextField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  textCapitalization: TextCapitalization.words,
                  autoCapitalizeFirst: true,
                  validator: (v) => _validateRequired(v, 'First Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Last Name Field - with auto-capitalization
                AppTextField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  textCapitalization: TextCapitalization.words,
                  autoCapitalizeFirst: true,
                  validator: (v) => _validateRequired(v, 'Last Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Nickname Field - with auto-capitalization
                AppTextField(
                  controller: _nicknameCtrl,
                  label: 'Nickname (Optional)',
                  hint: 'Enter your nickname',
                  textCapitalization: TextCapitalization.words,
                  autoCapitalizeFirst: true,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // International Phone Number Field
                InternationalPhoneField(
                  controller: _phoneCtrl,
                  validator: (v) {
                    if (_selectedCountry == null) return 'Please select country';
                    return null;
                  },
                  onCountryChanged: (country) {
                    setState(() {
                      _selectedCountry = country;
                    });
                  },
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Birthdate Picker
                DatePickerField.dateOnly(
                  selectedDateTime: _birthdate,
                  label: 'Birthdate',
                  hint: 'Select your birthdate',
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  minimumAgeYears: 12, // 12-year minimum age
                  onDateTimeSelected: (date) => setState(() => _birthdate = date),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Gender Dropdown using custom styling
                DropdownButtonFormField<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    hintText: 'Select your gender',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MethodistTheme.primaryRed,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: MethodistTheme.mediumGray.withOpacity(0.3),
                      ),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: MethodistTheme.spacingM,
                      vertical: MethodistTheme.spacingM,
                    ),
                  ),
                  style: MethodistTheme.bodyMedium,
                  dropdownColor: MethodistTheme.white,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: MethodistTheme.primaryRed,
                  ),
                  validator: (v) => v == null ? 'Please select gender' : null,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // District and MYF Selection with "Other" support
                DistrictMyfDropdowns(
                  selectedDistrict: _selectedDistrict,
                  selectedMyf: _selectedMyf,
                  onDistrictChanged: (district) => setState(() {
                    _selectedDistrict = district;
                    _selectedMyf = null; // Clear MYF when district changes
                  }),
                  onMyfChanged: (myf) => setState(() => _selectedMyf = myf),
                  districtValidator: _validateDistrict,
                  myfValidator: _validateMyf,
                  districts: DistrictData.districts,
                  districtMyfMap: DistrictData.districtMyfMap,
                ),

                SizedBox(height: MethodistTheme.spacingXL),

                // Submit Button
                PrimaryButton(
                  label: 'Complete Profile',
                  onPressed: _submit,
                  loading: _loading,
                  fullWidth: true,
                  icon: Icons.check,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Dynamic Helper Text Card
                Container(
                  padding: MethodistTheme.paddingS,
                  decoration: BoxDecoration(
                    color: MethodistTheme.infoBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
                    border: Border.all(
                      color: MethodistTheme.infoBlue.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: MethodistTheme.infoBlue,
                        size: 16,
                      ),
                      SizedBox(width: MethodistTheme.spacingS),
                      Expanded(
                        child: Text(
                          _isOtherDistrictSelected
                              ? 'You selected "Other" district. Please manually enter your church/MYF name.'
                              : 'Select your district first, then choose your church/MYF from the available options.',
                          style: MethodistTheme.bodySmall.copyWith(
                            color: MethodistTheme.infoBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MethodistTheme.spacingL),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
