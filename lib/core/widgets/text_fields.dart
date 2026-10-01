import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myf_connect/core/themes/theme.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final bool obscureText;
  final int maxLines;
  final int? maxLength;
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final bool autoCapitalizeFirst;

  const AppTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hint,
    this.validator,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.maxLines = 1,
    this.maxLength,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autoCapitalizeFirst = false,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<TextInputFormatter> formatters = widget.inputFormatters ?? [];

    if (widget.autoCapitalizeFirst) {
      formatters.add(_FirstLetterCapitalFormatter());
    }

    return TextFormField(
      controller: widget.controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: TextStyle(fontSize: context.responsiveFontSize(14)),
        hintText: widget.hint,
        hintStyle: TextStyle(fontSize: context.responsiveFontSize(13)),
        prefixIcon: widget.prefixIcon != null
            ? Transform.scale(
                scale: MediaQuery.sizeOf(context).width / 375,
                child: widget.prefixIcon!,
              )
            : null,
        suffixIcon: widget.suffixIcon,
        counterText: widget.maxLength != null ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyfTheme.primaryRed, width: 2),
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MyfTheme.mediumGray.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: MyfTheme.errorRed),
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        ),
        contentPadding: context.responsivePadding(horizontal: 16, vertical: 14),
        errorStyle: TextStyle(fontSize: context.responsiveFontSize(12)),
      ),
      style: TextStyle(fontSize: context.responsiveFontSize(15)),
      textCapitalization: widget.textCapitalization,
      onChanged: widget.onChanged,
      validator: widget.validator,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      maxLines: widget.obscureText ? 1 : widget.maxLines,
      minLines: widget.maxLines == 1 ? null : 1,
      maxLength: widget.maxLength,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      inputFormatters: formatters,
    );
  }
}

class _FirstLetterCapitalFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    final text = newValue.text;
    final capitalizedText =
        text[0].toUpperCase() + (text.length > 1 ? text.substring(1) : '');

    return newValue.copyWith(
      text: capitalizedText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: newValue.selection.end),
      ),
    );
  }
}
