import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../widgets/widgets.dart';
import '../../../models/district_data.dart';
import '../../../app/app_router.dart';

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
  final _otherMyfCtrl = TextEditingController(); // ✅ Added controller for "Other" district

  DateTime? _birthdate;
  String? _gender;
  String? _selectedDistrict;
  String? _selectedMyf;
  bool _loading = false;

  // Initialize with India as default
  CountryData? _selectedCountry = const CountryData(
    name: 'India',
    code: 'IN',
    dialCode: '91',
    minLength: 10,
    maxLength: 10,
  );

  // Check if "Other" district is selected
  bool get isOtherDistrictSelected => _selectedDistrict == 'Other';

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
        });
        debugPrint('SignupDetailsPage: Auto-filled from Google - First: ${_firstNameCtrl.text}, Last: ${_lastNameCtrl.text}, Nickname: ${_nicknameCtrl.text}');
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _otherMyfCtrl.dispose(); // ✅ Dispose the new controller
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
      return isOtherDistrictSelected
          ? 'Please enter your church/MYF'
          : 'Please select your church/MYF';
    }

    if (!isOtherDistrictSelected && !DistrictData.isValidMyfForDistrict(_selectedDistrict!, value)) {
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
      MethodistTheme.showErrorSnackBar(
        context,
        'Please ${isOtherDistrictSelected ? 'enter' : 'select'} your church/MYF',
      );
      return;
    }

    if (_selectedCountry == null) {
      MethodistTheme.showErrorSnackBar(context, 'Please select country code');
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      MethodistTheme.showErrorSnackBar(
        context,
        'Authentication error. Please restart app.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final userRef = FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid);

      // ✅ Create user document with all required fields
      await userRef.set({
        'email': firebaseUser.email,
        'phone': '${_selectedCountry!.dialCode}${_phoneCtrl.text.trim()}',
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
        'permissions': [], // ✅ CRITICAL: Empty array for new users
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
      debugPrint('Error saving profile: $e');
      if (mounted) {
        MethodistTheme.showErrorSnackBar(context, 'Error saving profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
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
                        child: const Icon(
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

                // First Name Field
                AppTextField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  hint: 'Enter your first name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'First Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Last Name Field
                AppTextField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  hint: 'Enter your last name',
                  textCapitalization: TextCapitalization.words,
                  validator: (v) => _validateRequired(v, 'Last Name'),
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Nickname Field (Optional)
                AppTextField(
                  controller: _nicknameCtrl,
                  label: 'Nickname (Optional)',
                  hint: 'Enter your nickname',
                  textCapitalization: TextCapitalization.words,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // International Phone Number Field
                InternationalPhoneField(
                  controller: _phoneCtrl,
                  onCountryChanged: (country) {
                    setState(() => _selectedCountry = country);
                  },
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Birthdate Field
                DatePickerField.dateOnly(
                  selectedDateTime: _birthdate,
                  label: 'Birthdate',
                  hint: 'Select your birthdate',
                  minimumAgeYears: 5,
                  onDateTimeSelected: (date) {
                    setState(() => _birthdate = date);
                  },
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    hintText: 'Select your gender',
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Male', child: Text('Male')),
                    DropdownMenuItem(value: 'Female', child: Text('Female')),
                  ],
                  onChanged: (value) {
                    setState(() => _gender = value);
                  },
                  validator: (v) => v == null ? 'Please select gender' : null,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // District Dropdown
                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: const InputDecoration(
                    labelText: 'District',
                    hintText: 'Select your district',
                  ),
                  items: DistrictData.districts.map((district) {
                    return DropdownMenuItem(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDistrict = value;
                      _selectedMyf = null; // Reset MYF when district changes
                      _otherMyfCtrl.clear(); // ✅ Clear the text field too
                    });
                  },
                  validator: _validateDistrict,
                ),

                SizedBox(height: MethodistTheme.spacingM),

                // Church/MYF Field (conditional dropdown for regular districts)
                if (_selectedDistrict != null && !isOtherDistrictSelected)
                  DropdownButtonFormField<String>(
                    value: _selectedMyf,
                    decoration: const InputDecoration(
                      labelText: 'Church/MYF',
                      hintText: 'Select your church/MYF',
                    ),
                    items: DistrictData.getMyfsByDistrict(_selectedDistrict!).map((myf) {
                      return DropdownMenuItem(
                        value: myf,
                        child: Text(myf),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedMyf = value);
                    },
                    validator: _validateMyf,
                  ),

                // Church/MYF Text Field (for "Other" district)
                if (_selectedDistrict != null && isOtherDistrictSelected)
                  AppTextField(
                    controller: _otherMyfCtrl, // ✅ FIXED: Now has controller
                    onChanged: (value) {
                      setState(() => _selectedMyf = value);
                    },
                    label: 'Church/MYF',
                    hint: 'Enter your church/MYF name',
                    textCapitalization: TextCapitalization.words,
                    validator: _validateMyf,
                  ),

                SizedBox(height: MethodistTheme.spacingL),

                // Submit Button
                Column(
                  children: [
                    PrimaryButton(
                      label: 'Complete Registration',
                      onPressed: _submit,
                      loading: _loading,
                      fullWidth: true,
                      icon: Icons.check_circle,
                    ),
                    SizedBox(height: MethodistTheme.spacingM),
                    PrimaryButton.secondary(
                      label: 'Cancel',
                      onPressed: _loading ? null : () => Navigator.pop(context),
                      fullWidth: true,
                      icon: Icons.cancel,
                    ),
                  ],
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
