import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:myf_connect/core/themes/theme.dart';

class CountryData {
  final String name;
  final String code;
  final String dialCode;
  final int minLength;
  final int maxLength;

  const CountryData({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.minLength,
    required this.maxLength,
  });
}

class InternationalPhoneField extends StatefulWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;
  final String? initialCountryCode;
  final ValueChanged<CountryData>? onCountryChanged;

  const InternationalPhoneField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
    this.initialCountryCode = 'IN',
    this.onCountryChanged,
  });

  @override
  State<InternationalPhoneField> createState() =>
      _InternationalPhoneFieldState();
}

class _InternationalPhoneFieldState extends State<InternationalPhoneField> {
  late CountryData _selectedCountry;

  static const List<CountryData> _countries = [
    CountryData(
      name: 'India',
      code: 'IN',
      dialCode: '+91',
      minLength: 10,
      maxLength: 10,
    ),
    CountryData(
      name: 'United States',
      code: 'US',
      dialCode: '+1',
      minLength: 10,
      maxLength: 10,
    ),
    CountryData(
      name: 'United Kingdom',
      code: 'GB',
      dialCode: '+44',
      minLength: 10,
      maxLength: 11,
    ),
    CountryData(
      name: 'Canada',
      code: 'CA',
      dialCode: '+1',
      minLength: 10,
      maxLength: 10,
    ),
    CountryData(
      name: 'Australia',
      code: 'AU',
      dialCode: '+61',
      minLength: 9,
      maxLength: 9,
    ),
    CountryData(
      name: 'Germany',
      code: 'DE',
      dialCode: '+49',
      minLength: 10,
      maxLength: 12,
    ),
    CountryData(
      name: 'France',
      code: 'FR',
      dialCode: '+33',
      minLength: 9,
      maxLength: 10,
    ),
    CountryData(
      name: 'Japan',
      code: 'JP',
      dialCode: '+81',
      minLength: 10,
      maxLength: 11,
    ),
    CountryData(
      name: 'China',
      code: 'CN',
      dialCode: '+86',
      minLength: 11,
      maxLength: 11,
    ),
    CountryData(
      name: 'Brazil',
      code: 'BR',
      dialCode: '+55',
      minLength: 10,
      maxLength: 11,
    ),
    CountryData(
      name: 'South Africa',
      code: 'ZA',
      dialCode: '+27',
      minLength: 9,
      maxLength: 9,
    ),
    CountryData(
      name: 'Singapore',
      code: 'SG',
      dialCode: '+65',
      minLength: 8,
      maxLength: 8,
    ),
    CountryData(
      name: 'UAE',
      code: 'AE',
      dialCode: '+971',
      minLength: 9,
      maxLength: 9,
    ),
    CountryData(
      name: 'Saudi Arabia',
      code: 'SA',
      dialCode: '+966',
      minLength: 9,
      maxLength: 9,
    ),
    CountryData(
      name: 'Nepal',
      code: 'NP',
      dialCode: '+977',
      minLength: 10,
      maxLength: 10,
    ),
    CountryData(
      name: 'Bangladesh',
      code: 'BD',
      dialCode: '+880',
      minLength: 10,
      maxLength: 10,
    ),
    CountryData(
      name: 'Sri Lanka',
      code: 'LK',
      dialCode: '+94',
      minLength: 9,
      maxLength: 9,
    ),
    CountryData(
      name: 'Pakistan',
      code: 'PK',
      dialCode: '+92',
      minLength: 10,
      maxLength: 10,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.firstWhere(
      (country) => country.code == widget.initialCountryCode,
      orElse: () => _countries.first,
    );
  }

  CountryData get selectedCountry => _selectedCountry;

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }

    final cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    if (cleanValue.length < _selectedCountry.minLength) {
      return 'Enter at least ${_selectedCountry.minLength} digits';
    }

    if (cleanValue.length > _selectedCountry.maxLength) {
      return 'Enter maximum ${_selectedCountry.maxLength} digits';
    }

    return widget.validator?.call(value);
  }

  void _selectCountry() async {
    final country = await showModalBottomSheet<CountryData>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MyfTheme.radiusL),
        ),
      ),
      builder: (context) => Container(
        padding: MyfTheme.paddingM,
        height: MediaQuery.of(context).size.height * 0.6,
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: MyfTheme.spacingM),
              decoration: BoxDecoration(
                color: MyfTheme.mediumGray,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text('Select Country', style: MyfTheme.titleLarge),
            const SizedBox(height: MyfTheme.spacingM),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (context, index) {
                  final country = _countries[index];
                  return ListTile(
                    title: Text(country.name),
                    subtitle: Text(
                      '${country.dialCode} (${country.minLength}-${country.maxLength} digits)',
                    ),
                    leading: Container(
                      width: 40,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MyfTheme.lightGray,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        country.code,
                        style: MyfTheme.bodySmall.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    selected: country.code == _selectedCountry.code,
                    onTap: () => context.pop(country),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (country != null && country.code != _selectedCountry.code) {
      setState(() {
        _selectedCountry = country;
        widget.controller.clear();
      });
      widget.onCountryChanged?.call(country);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        InkWell(
          onTap: widget.enabled ? _selectCountry : null,
          borderRadius: BorderRadius.circular(MyfTheme.radiusM),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: MyfTheme.spacingM,
              vertical: MyfTheme.spacingM + 2,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: MyfTheme.mediumGray.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(MyfTheme.radiusM),
              color: widget.enabled ? MyfTheme.white : MyfTheme.lightGray,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 24,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MyfTheme.primaryRed.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Text(
                    _selectedCountry.code,
                    style: MyfTheme.bodySmall.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: MyfTheme.primaryRed,
                    ),
                  ),
                ),
                const SizedBox(width: MyfTheme.spacingS),
                Text(_selectedCountry.dialCode, style: MyfTheme.bodyMedium),
                const SizedBox(width: MyfTheme.spacingXS),
                Icon(
                  Icons.arrow_drop_down,
                  color: widget.enabled
                      ? MyfTheme.mediumGray
                      : MyfTheme.lightGray,
                  size: 20,
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: MyfTheme.spacingS),

        Expanded(
          child: TextFormField(
            controller: widget.controller,
            decoration: InputDecoration(
              labelText: 'Mobile Number',
              hintText:
                  '${_selectedCountry.minLength}-${_selectedCountry.maxLength} digits',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(MyfTheme.radiusM),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: MyfTheme.primaryRed, width: 2),
                borderRadius: BorderRadius.circular(MyfTheme.radiusM),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: MyfTheme.mediumGray.withValues(alpha: 0.3),
                ),
                borderRadius: BorderRadius.circular(MyfTheme.radiusM),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: MyfTheme.spacingM,
                vertical: MyfTheme.spacingM,
              ),
            ),
            keyboardType: TextInputType.phone,
            enabled: widget.enabled,
            validator: _validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(_selectedCountry.maxLength),
            ],
          ),
        ),
      ],
    );
  }
}
