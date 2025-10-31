// lib/widgets/date_picker_field.dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

class DatePickerField extends StatefulWidget {
  final DateTime? selectedDateTime;
  final String label;
  final String hint;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final void Function(DateTime)? onDateTimeSelected;
  final bool _isDateOnly;

  /// For birthdate - date only
  const DatePickerField.dateOnly({
    super.key,
    this.selectedDateTime,
    required this.label,
    required this.hint,
    this.firstDate,
    this.lastDate,
    this.onDateTimeSelected,
  }) : _isDateOnly = true;

  /// For events - date + time
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
          color: MethodistTheme.white,
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
                      fontWeight: FontWeight.w500,
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

  /// ✅ COMPLETE FIX: Properly handle initialDate within valid range
  Future<void> _showDatePicker(BuildContext context) async {
    final now = DateTime.now();

    // ✅ Set proper date constraints for birthdate
    final effectiveFirstDate = widget.firstDate ?? DateTime(1900);
    final effectiveLastDate = widget.lastDate ?? now;

    // ✅ CRITICAL: Calculate safe initialDate within range
    late DateTime effectiveInitialDate;

    if (widget.selectedDateTime != null) {
      // Use selected date if provided
      effectiveInitialDate = widget.selectedDateTime!;
    } else {
      // For new selection: start from a middle year (e.g., 2000) if no previous selection
      // This ensures the year picker shows a reasonable range
      if (now.year > 2000) {
        effectiveInitialDate = DateTime(2000);
      } else {
        effectiveInitialDate = now;
      }
    }

    // Ensure initialDate is within valid range
    if (effectiveInitialDate.isBefore(effectiveFirstDate)) {
      effectiveInitialDate = effectiveFirstDate;
    }
    if (effectiveInitialDate.isAfter(effectiveLastDate)) {
      effectiveInitialDate = effectiveLastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: effectiveInitialDate,
      firstDate: effectiveFirstDate,
      lastDate: effectiveLastDate,
      helpText: 'Select your birthdate',
      errorInvalidText: 'Invalid date',
    );

    if (picked != null && widget.onDateTimeSelected != null) {
      widget.onDateTimeSelected!(picked);
    }
  }

  /// Date + Time picker for events
  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();

    // First pick date
    final date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDateTime ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 1),
      lastDate: widget.lastDate ?? DateTime(now.year + 2),
      helpText: 'Select date',
    );

    if (date == null || !context.mounted) return;

    // Then pick time
    final time = await showTimePicker(
      context: context,
      initialTime: widget.selectedDateTime != null
          ? TimeOfDay.fromDateTime(widget.selectedDateTime!)
          : TimeOfDay.now(),
      helpText: 'Select time',
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
