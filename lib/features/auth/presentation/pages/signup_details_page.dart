import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/auth/data/models/district_data.dart';
import 'package:myf_connect/features/auth/data/models/app_user.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/core/config/app_router.dart';
import 'package:myf_connect/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:myf_connect/features/auth/presentation/widgets/international_phone_field.dart';
import 'package:myf_connect/core/utils/validators.dart';
import 'package:myf_connect/features/auth/presentation/widgets/signup/signup_header_card.dart';
import 'package:myf_connect/features/auth/presentation/widgets/signup/district_myf_selector.dart';

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
  final _otherMyfCtrl = TextEditingController();

  DateTime? _birthdate;
  String? _gender;
  String? _selectedDistrict;
  String? _selectedMyf;
  bool _loading = false;

  CountryData? _selectedCountry = const CountryData(
    name: 'India',
    code: 'IN',
    dialCode: '91',
    minLength: 10,
    maxLength: 10,
  );

  bool get isOtherDistrictSelected => _selectedDistrict == 'Other';

  @override
  void initState() {
    super.initState();
    _autoFillFromArguments();
  }

  void _autoFillFromArguments() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _firstNameCtrl.text = args['firstName'] ?? '';
          _lastNameCtrl.text = args['lastName'] ?? '';
          _nicknameCtrl.text = args['nickname'] ?? '';
        });
        debugPrint(
          'SignupDetailsPage: Auto-filled from Google - First: ${_firstNameCtrl.text}, Last: ${_lastNameCtrl.text}, Nickname: ${_nicknameCtrl.text}',
        );
      }
    });
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _nicknameCtrl.dispose();
    _phoneCtrl.dispose();
    _otherMyfCtrl.dispose();
    super.dispose();
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

    if (!isOtherDistrictSelected &&
        !DistrictData.isValidMyfForDistrict(_selectedDistrict!, value)) {
      return 'Please select a valid church/MYF for your district';
    }

    return null;
  }

  Future<void> _submit() async {
    if (_loading) return;

    if (!_formKey.currentState!.validate()) return;

    if (_birthdate == null) {
      MyfTheme.showErrorSnackBar(context, 'Please select your birthdate');
      return;
    }

    if (_gender == null) {
      MyfTheme.showErrorSnackBar(context, 'Please select gender');
      return;
    }

    if (_selectedDistrict == null) {
      MyfTheme.showErrorSnackBar(context, 'Please select your district');
      return;
    }

    if (_selectedMyf == null || _selectedMyf!.isEmpty) {
      MyfTheme.showErrorSnackBar(
        context,
        'Please ${isOtherDistrictSelected ? 'enter' : 'select'} your church/MYF',
      );
      return;
    }

    if (_selectedCountry == null) {
      MyfTheme.showErrorSnackBar(context, 'Please select country code');
      return;
    }

    final firebaseUser = FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) {
      MyfTheme.showErrorSnackBar(
        context,
        'Authentication error. Please restart app.',
      );
      return;
    }

    setState(() => _loading = true);

    try {
      final appUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email,
        phone: '${_selectedCountry!.dialCode}${_phoneCtrl.text.trim()}',
        firstName: _firstNameCtrl.text.trim(),
        lastName: _lastNameCtrl.text.trim(),
        nickname: _nicknameCtrl.text.trim().isNotEmpty
            ? _nicknameCtrl.text.trim()
            : null,
        birthdate: _birthdate,
        gender: _gender,
        district: _selectedDistrict,
        church: _selectedMyf,
      );

      final userRepository = UserRepository();
      await userRepository.createOrUpdateUser(appUser);

      if (mounted) {
        // Dispatch AuthCheckRequested so state becomes AuthAuthenticated
        context.read<AuthBloc>().add(AuthCheckRequested());

        context.go(AppRoutes.mainMenu);
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        MyfTheme.showErrorSnackBar(context, 'Error saving profile: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _handleCancel() async {
    try {
      context.read<AuthBloc>().add(AuthDeleteAccountRequested());

      if (mounted) {
        context.go(AppRoutes.welcome);
      }
    } catch (e) {
      debugPrint('Error during cancel: $e');
      if (mounted) {
        MyfTheme.showErrorSnackBar(context, 'Error canceling signup: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyfTheme.lightGray,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: context.responsiveHeadlineSmall.copyWith(
            color: MyfTheme.white,
          ),
        ),
        backgroundColor: MyfTheme.primaryRed,
        foregroundColor: MyfTheme.white,
      ),
      body: LoadingOverlay(
        isLoading: _loading,
        loadingMessage: 'Saving profile...',
        child: SingleChildScrollView(
          padding: context.responsivePadding(all: 24),
          child: ResponsiveConstrainedBox(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SignupHeaderCard(),

                  SizedBox(height: context.spacing(24)),

                  AppTextField(
                    controller: _firstNameCtrl,
                    label: 'First Name',
                    hint: 'Enter your first name',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => AppValidators.required(v, 'First Name'),
                  ),

                  SizedBox(height: context.spacing(16)),

                  AppTextField(
                    controller: _lastNameCtrl,
                    label: 'Last Name',
                    hint: 'Enter your last name',
                    textCapitalization: TextCapitalization.words,
                    validator: (v) => AppValidators.required(v, 'Last Name'),
                  ),

                  SizedBox(height: context.spacing(16)),

                  AppTextField(
                    controller: _nicknameCtrl,
                    label: 'Nickname (Optional)',
                    hint: 'Enter your nickname',
                    textCapitalization: TextCapitalization.words,
                  ),

                  SizedBox(height: context.spacing(16)),

                  InternationalPhoneField(
                    controller: _phoneCtrl,
                    onCountryChanged: (country) {
                      setState(() => _selectedCountry = country);
                    },
                  ),

                  SizedBox(height: context.spacing(16)),

                  DatePickerField.dateOnly(
                    selectedDateTime: _birthdate,
                    label: 'Birthdate',
                    hint: 'Select your birthdate',
                    onDateTimeSelected: (date) {
                      setState(() => _birthdate = date);
                    },
                  ),

                  SizedBox(height: context.spacing(16)),

                  DropdownButtonFormField<String>(
                    initialValue: _gender,
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(
                        fontSize: context.responsiveFontSize(14),
                      ),
                      hintText: 'Select your gender',
                      hintStyle: TextStyle(
                        fontSize: context.responsiveFontSize(13),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          context.responsiveRadius(12),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: MyfTheme.primaryRed,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(
                          context.responsiveRadius(12),
                        ),
                      ),
                      contentPadding: context.responsivePadding(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    items: [
                      DropdownMenuItem(
                        value: 'Male',
                        child: Text(
                          'Male',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(14),
                          ),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Female',
                        child: Text(
                          'Female',
                          style: TextStyle(
                            fontSize: context.responsiveFontSize(14),
                          ),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() => _gender = value);
                    },
                    validator: (v) => v == null ? 'Please select gender' : null,
                  ),

                  SizedBox(height: context.spacing(16)),

                  DistrictMyfSelector(
                    selectedDistrict: _selectedDistrict,
                    selectedMyf: _selectedMyf,
                    otherMyfController: _otherMyfCtrl,
                    onDistrictChanged: (value) {
                      setState(() {
                        _selectedDistrict = value;
                        _selectedMyf = null;
                        _otherMyfCtrl.clear();
                      });
                    },
                    onMyfChanged: (value) {
                      setState(() => _selectedMyf = value);
                    },
                    districtValidator: _validateDistrict,
                    myfValidator: _validateMyf,
                  ),

                  SizedBox(height: context.spacing(24)),

                  Column(
                    children: [
                      PrimaryButton(
                        label: 'Complete Registration',
                        onPressed: _submit,
                        loading: _loading,
                        fullWidth: true,
                        icon: Icons.check_circle,
                      ),
                      SizedBox(height: context.spacing(12)),
                      PrimaryButton.secondary(
                        label: 'Cancel',
                        onPressed: _loading ? null : _handleCancel,
                        fullWidth: true,
                        icon: Icons.cancel,
                      ),
                    ],
                  ),

                  SizedBox(height: context.spacing(24)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
