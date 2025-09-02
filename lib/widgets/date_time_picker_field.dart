// lib/widgets/date_time_picker_field.dart
import 'package:flutter/material.dart';
import '../app/theme.dart';

class DateTimePickerField extends StatelessWidget {
  final DateTime? selectedDateTime;
  final String label;
  final String? hint;
  final ValueChanged<DateTime?>? onDateTimeSelected;
  final bool enabled;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool showTimeOnly;

  const DateTimePickerField({
    super.key,
    this.selectedDateTime,
    required this.label,
    this.hint,
    this.onDateTimeSelected,
    this.enabled = true,
    this.firstDate,
    this.lastDate,
    this.showTimeOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? () => _showDateTimePicker(context) : null,
      borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
      child: Container(
        padding: MethodistTheme.paddingM,
        decoration: BoxDecoration(
          color: MethodistTheme.white,
          border: Border.all(
            color: MethodistTheme.mediumGray.withOpacity(0.3),
          ),
          borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
        ),
        child: Row(
          children: [
            Icon(
              showTimeOnly ? Icons.access_time : Icons.calendar_today,
              color: MethodistTheme.primaryRed,
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
                    selectedDateTime == null
                        ? (hint ?? 'Select ${showTimeOnly ? 'time' : 'date & time'}')
                        : _formatDateTime(context, selectedDateTime!),
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
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    if (showTimeOnly) {
      return TimeOfDay.fromDateTime(dateTime).format(context);
    }
    return dateTime.toLocal().toString().split('.').first;
  }

  Future<void> _showDateTimePicker(BuildContext context) async {
    if (showTimeOnly) {
      await _showTimePicker(context);
      return;
    }

    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDateTime ?? now,
      firstDate: firstDate ?? DateTime(now.year - 1),
      lastDate: lastDate ?? DateTime(now.year + 2),
    );

    if (date == null || !context.mounted) return;

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
}
