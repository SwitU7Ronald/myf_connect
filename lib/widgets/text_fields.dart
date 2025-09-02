// lib/widgets/text_fields.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextCapitalization textCapitalization;
  final Function(String)? onChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int? maxLines;
  final int? maxLength;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoCapitalizeFirst;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.textCapitalization = TextCapitalization.none,
    this.onChanged,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.autoCapitalizeFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = inputFormatters ?? [];

    // Add first letter capitalization formatter if needed
    if (autoCapitalizeFirst) {
      formatters.add(_FirstLetterCapitalFormatter());
    }

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
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
        contentPadding: const EdgeInsets.symmetric(
          horizontal: MethodistTheme.spacingM,
          vertical: MethodistTheme.spacingM,
        ),
      ),
      textCapitalization: textCapitalization,
      onChanged: onChanged,
      validator: validator,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLines: maxLines,
      maxLength: maxLength,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: formatters,
    );
  }
}

// Custom formatter for first letter capitalization
class _FirstLetterCapitalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue,
      TextEditingValue newValue,
      ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final String newText = newValue.text;
    String capitalizedText = '';

    for (int i = 0; i < newText.length; i++) {
      if (i == 0 || (i > 0 && newText[i - 1] == ' ')) {
        capitalizedText += newText[i].toUpperCase();
      } else {
        capitalizedText += newText[i].toLowerCase();
      }
    }

    return TextEditingValue(
      text: capitalizedText,
      selection: newValue.selection,
    );
  }
}

// Keep existing PhoneTextField for backward compatibility
class PhoneTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool enabled;

  const PhoneTextField({
    super.key,
    required this.controller,
    this.validator,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MethodistTheme.spacingM,
            vertical: MethodistTheme.spacingM,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: MethodistTheme.lightGray),
            borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
            color: MethodistTheme.white,
          ),
          child: Text(
            '+91',
            style: MethodistTheme.bodyMedium,
          ),
        ),
        SizedBox(width: MethodistTheme.spacingS),
        Expanded(
          child: AppTextField(
            controller: controller,
            label: 'Mobile Number',
            hint: '10-digit number',
            keyboardType: TextInputType.phone,
            validator: validator,
            enabled: enabled,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),
        ),
      ],
    );
  }
}

class SearchTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SearchTextField({
    super.key,
    required this.controller,
    this.hint,
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: controller,
      label: 'Search',
      hint: hint ?? 'Search...',
      prefixIcon: const Icon(Icons.search),
      suffixIcon: controller.text.isNotEmpty && onClear != null
          ? IconButton(
        icon: const Icon(Icons.clear),
        onPressed: onClear,
      )
          : null,
      onChanged: onChanged,
    );
  }
}
