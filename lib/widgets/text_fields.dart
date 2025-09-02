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
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: maxLength != null ? null : '',
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
      inputFormatters: inputFormatters,
    );
  }
}

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

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDate;
  final String label;
  final String? hint;
  final ValueChanged<DateTime?>? onDateSelected;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;

  const DatePickerField({
    super.key,
    this.selectedDate,
    required this.label,
    this.hint,
    this.onDateSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  });

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: TextEditingController(
        text: selectedDate?.toLocal().toString().split(' ').first ?? '',
      ),
      label: label,
      hint: hint ?? 'Select date',
      enabled: enabled,
      readOnly: true,
      suffixIcon: const Icon(Icons.calendar_today),
      onTap: enabled ? () => _showDatePicker(context) : null,
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: firstDate ?? DateTime(1900),
      lastDate: lastDate ?? DateTime(now.year + 100),
    );

    if (picked != null && onDateSelected != null) {
      onDateSelected!(picked);
    }
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