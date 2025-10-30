import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app/theme.dart';

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
        labelStyle: TextStyle(
          fontSize: context.responsiveFontSize(14),
        ),
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: context.responsiveFontSize(13),
        ),
        prefixIcon: widget.prefixIcon != null
            ? Transform.scale(
          scale: MediaQuery.sizeOf(context).width / 375,
          child: widget.prefixIcon!,
        )
            : null,
        suffixIcon: widget.suffixIcon,
        counterText: widget.maxLength != null ? null : '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            context.responsiveRadius(12),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MethodistTheme.primaryRed,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(
            context.responsiveRadius(12),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(
            context.responsiveRadius(12),
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: MethodistTheme.errorRed,
          ),
          borderRadius: BorderRadius.circular(
            context.responsiveRadius(12),
          ),
        ),
        contentPadding: context.responsivePadding(
          horizontal: 16,
          vertical: 14,
        ),
        errorStyle: TextStyle(
          fontSize: context.responsiveFontSize(12),
        ),
      ),
      style: TextStyle(
        fontSize: context.responsiveFontSize(15),
      ),
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

class DatePickerField extends StatefulWidget {
  final DateTime? selectedDateTime;
  final String label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateTimeSelected;
  final bool _isDateOnly;

  const DatePickerField.dateOnly({
    super.key,
    this.selectedDateTime,
    required this.label,
    required this.hint,
    this.firstDate,
    this.lastDate,
    this.onDateTimeSelected,
  }) : _isDateOnly = true;

  const DatePickerField.dateTime({
    super.key,
    this.selectedDateTime,
    required this.label,
    required this.hint,
    this.firstDate,
    this.lastDate,
    this.onDateTimeSelected,
  }) : _isDateOnly = false;

  @override
  State<DatePickerField> createState() => _DatePickerFieldState();
}

class _DatePickerFieldState extends State<DatePickerField> {
  @override
  Widget build(BuildContext context) {
    final selectedText = widget.selectedDateTime != null
        ? widget._isDateOnly
        ? widget.selectedDateTime!.toLocal().toString().split(' ').first
        : widget.selectedDateTime!.toLocal().toString().split('.').first
        : 'Select ${widget._isDateOnly ? 'date' : 'date & time'}';

    return InkWell(
      onTap: widget._isDateOnly
          ? () => _showDatePicker(context)
          : () => _showDateTimePicker(context),
      borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
      child: Container(
        padding: context.responsivePadding(
          horizontal: 16,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: MethodistTheme.mediumGray.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
        ),
        child: Row(
          children: [
            Icon(
              widget._isDateOnly ? Icons.calendar_today : Icons.access_time,
              color: MethodistTheme.primaryRed,
              size: context.responsiveIconSize(20),
            ),
            SizedBox(width: context.spacing(12)),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(12),
                      color: MethodistTheme.mediumGray,
                    ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    selectedText,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      color: widget.selectedDateTime == null
                          ? MethodistTheme.mediumGray
                          : MethodistTheme.darkGray,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.selectedDateTime ?? DateTime.now(),
      firstDate: widget.firstDate ?? DateTime(DateTime.now().year - 1),
      lastDate: widget.lastDate ?? DateTime(DateTime.now().year + 2),
    );

    if (picked != null && widget.onDateTimeSelected != null) {
      widget.onDateTimeSelected!(picked);
    }
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDateTime ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 1),
      lastDate: widget.lastDate ?? DateTime(now.year + 2),
    );

    if (date == null || !context.mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: widget.selectedDateTime != null
          ? TimeOfDay.fromDateTime(widget.selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (time != null && widget.onDateTimeSelected != null) {
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      widget.onDateTimeSelected!(combined);
    }
  }
}
