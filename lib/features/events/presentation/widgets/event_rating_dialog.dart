import 'package:flutter/material.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/themes/theme.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/auth/data/repositories/user_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';

/// A standalone dialog for submitting an event rating (1–5 stars).
///
/// Handles all business logic (permission check, duplicate check, submission)
/// internally. Notify callers of a successful submission via [onRatingSubmitted].
class EventRatingDialog extends StatefulWidget {
  final String eventId;
  final String campOrMyfId;
  final String eventTitle;
  final bool isCamp;
  final ValueChanged<int> onRatingSubmitted;

  const EventRatingDialog({
    super.key,
    required this.eventId,
    required this.campOrMyfId,
    required this.eventTitle,
    required this.isCamp,
    required this.onRatingSubmitted,
  });

  /// Shows this dialog and returns when dismissed.
  static Future<void> show({
    required BuildContext context,
    required String eventId,
    required String campOrMyfId,
    required String eventTitle,
    required bool isCamp,
    required ValueChanged<int> onRatingSubmitted,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => EventRatingDialog(
        eventId: eventId,
        campOrMyfId: campOrMyfId,
        eventTitle: eventTitle,
        isCamp: isCamp,
        onRatingSubmitted: onRatingSubmitted,
      ),
    );
  }

  @override
  State<EventRatingDialog> createState() => _EventRatingDialogState();
}

class _EventRatingDialogState extends State<EventRatingDialog> {
  int _selectedRating = 0;
  bool _isSubmitting = false;

  Future<void> _submit() async {
    if (_selectedRating < 1 || _selectedRating > 5) {
      MyfTheme.showErrorSnackBar(context, AppStrings.invalidRating);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = di.sl<AuthRepository>().currentUser;
      if (user == null) {
        if (mounted) MyfTheme.showErrorSnackBar(context, AppStrings.signInToRate);
        return;
      }

      final appUser = await di.sl<UserRepository>().getUser(user.uid);
      if (appUser == null) {
        if (mounted) MyfTheme.showErrorSnackBar(context, AppStrings.profileNotFound);
        return;
      }

      if (!appUser.permissions.contains(widget.campOrMyfId)) {
        if (mounted) {
          MyfTheme.showErrorSnackBar(
            context,
            '${AppStrings.noPermissionToRate} ${widget.isCamp ? 'camp' : 'MYF'}.',
          );
        }
        return;
      }

      final collection = widget.isCamp ? 'camps' : 'myfs';

      final existingRating = await di.sl<EventRepository>().getUserRating(
        collection: collection,
        parentId: widget.campOrMyfId,
        eventId: widget.eventId,
        userId: user.uid,
      );

      if (existingRating != null) {
        if (mounted) MyfTheme.showErrorSnackBar(context, AppStrings.alreadyRated);
        return;
      }

      await di.sl<EventRepository>().submitRating(
        collection: collection,
        parentId: widget.campOrMyfId,
        eventId: widget.eventId,
        userId: user.uid,
        rating: _selectedRating,
      );

      widget.onRatingSubmitted(_selectedRating);

      if (mounted) {
        MyfTheme.showSuccessSnackBar(context, AppStrings.ratingThankYou);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (mounted) {
        MyfTheme.showErrorSnackBar(context, 'Error submitting rating: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(AppStrings.rateEvent, style: context.responsiveHeadlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate "${widget.eventTitle}"?',
              style: context.responsiveBodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacing(24)),
            if (_isSubmitting)
              SizedBox(
                height: context.responsiveIconSize(40),
                width: context.responsiveIconSize(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(MyfTheme.primaryRed),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(horizontal: context.spacing(2)),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      iconSize: 32,
                      icon: Icon(
                        index < _selectedRating ? Icons.star : Icons.star_border,
                        color: MyfTheme.warningOrange,
                      ),
                      onPressed: () => setState(() => _selectedRating = index + 1),
                    ),
                  );
                }),
              ),
            SizedBox(height: context.spacing(12)),
            Text(
              _selectedRating > 0
                  ? '$_selectedRating Star${_selectedRating > 1 ? 's' : ''}'
                  : 'Tap to rate',
              style: context.responsiveBodySmall.copyWith(color: MyfTheme.mediumGray),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: TextStyle(fontSize: context.responsiveFontSize(14)),
          ),
        ),
        SizedBox(width: context.spacing(8)),
        ElevatedButton(
          onPressed: (_selectedRating > 0 && !_isSubmitting) ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: MyfTheme.primaryRed,
            foregroundColor: MyfTheme.white,
          ),
          child: Text(
            AppStrings.submit,
            style: TextStyle(fontSize: context.responsiveFontSize(14)),
          ),
        ),
      ],
    );
  }
}
