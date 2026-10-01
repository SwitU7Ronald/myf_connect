import 'package:flutter/material.dart';
import 'package:myf_connect/core/themes/theme.dart';

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
        padding: context.responsivePadding(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: MyfTheme.mediumGray.withValues(alpha: 0.3)),
          borderRadius: BorderRadius.circular(context.responsiveRadius(12)),
          color: MyfTheme.white,
        ),
        child: Row(
          children: [
            Icon(
              widget._isDateOnly ? Icons.calendar_today : Icons.access_time,
              color: MyfTheme.primaryRed,
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
                      color: MyfTheme.mediumGray,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: context.spacing(4)),
                  Text(
                    selectedText,
                    style: TextStyle(
                      fontSize: context.responsiveFontSize(14),
                      color: widget.selectedDateTime == null
                          ? MyfTheme.mediumGray
                          : MyfTheme.darkGray,
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
    final now = DateTime.now();

    final effectiveFirstDate = widget.firstDate ?? DateTime(1900);
    final effectiveLastDate = widget.lastDate ?? now;

    late DateTime effectiveInitialDate;

    if (widget.selectedDateTime != null) {
      effectiveInitialDate = widget.selectedDateTime!;
    } else {
      if (now.year > 2000) {
        effectiveInitialDate = DateTime(2000);
      } else {
        effectiveInitialDate = now;
      }
    }

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

  Future<void> _showDateTimePicker(BuildContext context) async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: widget.selectedDateTime ?? now,
      firstDate: widget.firstDate ?? DateTime(now.year - 1),
      lastDate: widget.lastDate ?? DateTime(now.year + 2),
      helpText: 'Select date',
    );

    if (date == null || !context.mounted) return;

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
