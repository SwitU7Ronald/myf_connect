// lib/widgets/date_picker_field.dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

enum DatePickerMode {
  dateOnly,     // Just date (for birthdate)
  timeOnly,     // Just time
  dateTime,     // Date + Time (for events)
}

class DatePickerField extends StatelessWidget {
  final DateTime? selectedDateTime;
  final String label;
  final String? hint;
  final ValueChanged<DateTime?>? onDateTimeSelected;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final DatePickerMode mode;
  final int? minimumAgeYears; // For age validation in dateOnly mode

  const DatePickerField({
    super.key,
    this.selectedDateTime,
    required this.label,
    this.hint,
    this.onDateTimeSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.mode = DatePickerMode.dateOnly,
    this.minimumAgeYears,
  });

  // Factory constructors for common use cases
  const DatePickerField.dateOnly({
    super.key,
    this.selectedDateTime,
    required this.label,
    this.hint,
    this.onDateTimeSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.minimumAgeYears,
  }) : mode = DatePickerMode.dateOnly;

  const DatePickerField.timeOnly({
    super.key,
    this.selectedDateTime,
    required this.label,
    this.hint,
    this.onDateTimeSelected,
    this.enabled = true,
  }) : mode = DatePickerMode.timeOnly,
        firstDate = null,
        lastDate = null,
        minimumAgeYears = null;

  const DatePickerField.dateTime({
    super.key,
    this.selectedDateTime,
    required this.label,
    this.hint,
    this.onDateTimeSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
  }) : mode = DatePickerMode.dateTime,
        minimumAgeYears = null;

  // Calculate maximum allowed birthdate for minimum age
  DateTime _getMaxAllowedBirthdate() {
    if (minimumAgeYears == null) return DateTime.now();

    final today = DateTime.now();
    return DateTime(
      today.year - minimumAgeYears!,
      today.month,
      today.day,
    );
  }

  // Validate age for dateOnly mode
  String? _validateAge(DateTime? birthdate) {
    if (minimumAgeYears == null || birthdate == null) return null;

    final today = DateTime.now();
    final age = today.year - birthdate.year;
    final hasHadBirthdayThisYear = today.month > birthdate.month ||
        (today.month == birthdate.month && today.day >= birthdate.day);

    final actualAge = hasHadBirthdayThisYear ? age : age - 1;

    if (actualAge < minimumAgeYears!) {
      return 'Must be at least $minimumAgeYears years old';
    }

    return null;
  }

  // Calculate age for display
  int? _calculateAge(DateTime? birthdate) {
    if (birthdate == null) return null;

    final today = DateTime.now();
    final age = today.year - birthdate.year;
    final hasHadBirthdayThisYear = today.month > birthdate.month ||
        (today.month == birthdate.month && today.day >= birthdate.day);

    return hasHadBirthdayThisYear ? age : age - 1;
  }

  IconData get _icon {
    switch (mode) {
      case DatePickerMode.dateOnly:
        return Icons.calendar_today;
      case DatePickerMode.timeOnly:
        return Icons.access_time;
      case DatePickerMode.dateTime:
        return Icons.calendar_today;
    }
  }

  String get _hintText {
    if (hint != null) return hint!;

    switch (mode) {
      case DatePickerMode.dateOnly:
        return 'Select date${minimumAgeYears != null ? " (min age: $minimumAgeYears years)" : ""}';
      case DatePickerMode.timeOnly:
        return 'Select time';
      case DatePickerMode.dateTime:
        return 'Select date & time';
    }
  }

  String _formatDisplayText(BuildContext context) {
    if (selectedDateTime == null) return _hintText;

    switch (mode) {
      case DatePickerMode.dateOnly:
        return selectedDateTime!.toLocal().toString().split(' ').first;
      case DatePickerMode.timeOnly:
        return TimeOfDay.fromDateTime(selectedDateTime!).format(context);
      case DatePickerMode.dateTime:
        return selectedDateTime!.toLocal().toString().split('.').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled ? () => _showPicker(context) : null,
          borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
          child: Container(
            padding: MethodistTheme.paddingM,
            decoration: BoxDecoration(
              color: enabled ? MethodistTheme.white : MethodistTheme.lightGray,
              border: Border.all(
                color: MethodistTheme.mediumGray.withOpacity(0.3),
              ),
              borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
            ),
            child: Row(
              children: [
                Icon(
                  _icon,
                  color: enabled ? MethodistTheme.primaryRed : MethodistTheme.mediumGray,
                  size: 20,
                ),
                SizedBox(width: MethodistTheme.spacingM),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: MethodistTheme.labelMedium.copyWith(
                          color: MethodistTheme.mediumGray,
                        ),
                      ),
                      SizedBox(height: MethodistTheme.spacingXS),
                      Text(
                        _formatDisplayText(context),
                        style: MethodistTheme.bodyMedium.copyWith(
                          color: selectedDateTime == null
                              ? MethodistTheme.mediumGray
                              : MethodistTheme.darkGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Age display for dateOnly mode with minimumAgeYears
        if (mode == DatePickerMode.dateOnly &&
            minimumAgeYears != null &&
            selectedDateTime != null) ...[
          SizedBox(height: MethodistTheme.spacingS),
          Container(
            padding: MethodistTheme.paddingS,
            decoration: BoxDecoration(
              color: _calculateAge(selectedDateTime)! >= minimumAgeYears!
                  ? MethodistTheme.successGreen.withOpacity(0.1)
                  : MethodistTheme.errorRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
              border: Border.all(
                color: _calculateAge(selectedDateTime)! >= minimumAgeYears!
                    ? MethodistTheme.successGreen.withOpacity(0.3)
                    : MethodistTheme.errorRed.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _calculateAge(selectedDateTime)! >= minimumAgeYears!
                      ? Icons.check_circle_outline
                      : Icons.error_outline,
                  color: _calculateAge(selectedDateTime)! >= minimumAgeYears!
                      ? MethodistTheme.successGreen
                      : MethodistTheme.errorRed,
                  size: 16,
                ),
                SizedBox(width: MethodistTheme.spacingS),
                Text(
                  'Age: ${_calculateAge(selectedDateTime)} years ${_calculateAge(selectedDateTime)! >= minimumAgeYears! ? "(✓ Eligible)" : "(✗ Too young)"}',
                  style: MethodistTheme.bodySmall.copyWith(
                    color: _calculateAge(selectedDateTime)! >= minimumAgeYears!
                        ? MethodistTheme.successGreen
                        : MethodistTheme.errorRed,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    switch (mode) {
      case DatePickerMode.dateOnly:
        await _showDatePicker(context);
        break;
      case DatePickerMode.timeOnly:
        await _showTimePicker(context);
        break;
      case DatePickerMode.dateTime:
        await _showDateTimePicker(context);
        break;
    }
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();

    // Calculate date constraints
    final DateTime effectiveFirstDate = firstDate ?? DateTime(1900);
    DateTime effectiveLastDate = lastDate ?? DateTime(now.year + 100);

    // If minimum age is specified, restrict the last selectable date
    if (minimumAgeYears != null) {
      final maxBirthdate = _getMaxAllowedBirthdate();
      effectiveLastDate = maxBirthdate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? effectiveLastDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      helpText: minimumAgeYears != null
          ? 'Select birthdate (minimum age: $minimumAgeYears years)'
          : null,
      errorInvalidText: minimumAgeYears != null
          ? 'Must be at least $minimumAgeYears years old'
          : null,
    );

    if (picked != null && onDateTimeSelected != null) {
      // Validate age if minimum age is required
      final ageError = _validateAge(picked);
      if (ageError != null) {
        // Show error and don't select the invalid date
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(ageError),
              backgroundColor: MethodistTheme.errorRed,
            ),
          );
        }
        return;
      }

      onDateTimeSelected!(picked);
    }
  }

  Future<void> _showTimePicker(BuildContext context) async {
    final time = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (time != null && onDateTimeSelected != null) {
      final now = DateTime.now();
      final combined = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      onDateTimeSelected!(combined);
    }
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();

    // First pick date
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: lastDate ?? DateTime(now.year + 2),
    );

    if (date == null || !context.mounted) return;

    // Then pick time
    final time = await showTimePicker(
      context: context,
      initialTime: selectedDateTime != null
          ? TimeOfDay.fromDateTime(selectedDateTime!)
          : TimeOfDay.now(),
    );

    if (time != null && onDateTimeSelected != null) {
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
      onDateTimeSelected!(combined);
    }
  }
}
