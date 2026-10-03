import 'package:flutter/material.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/widgets/platform_components.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/services/auth/auth_repository.dart';
import 'package:myf_connect/core/services/users/user_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_snackbars.dart';


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
      AppSnackbars.showError(context, AppStrings.invalidRating);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final user = di.sl<AuthRepository>().currentUser;
      if (user == null) {
        if (mounted) {
          AppSnackbars.showError(context, AppStrings.signInToRate);
        }
        return;
      }

      final appUser = await di.sl<UserRepository>().getUser(user.uid);
      if (appUser == null) {
        if (mounted) {
          AppSnackbars.showError(context, AppStrings.profileNotFound);
        }
        return;
      }

      if (!appUser.permissions.contains(widget.campOrMyfId)) {
        if (mounted) {
          AppSnackbars.showError(
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
        if (mounted) {
          AppSnackbars.showError(context, AppStrings.alreadyRated);
        }
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
        AppSnackbars.showSuccess(context, AppStrings.ratingThankYou);
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (mounted) {
        AppSnackbars.showError(context, 'Error submitting rating: $e');
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      title: Text(AppStrings.rateEvent, style: context.typography.headlineSmall),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'How would you rate "${widget.eventTitle}"?',
              style: context.typography.bodyMedium,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.spacingLg),
            if (_isSubmitting)
              SizedBox(
                height: context.responsiveIconSize(40),
                width: context.responsiveIconSize(40),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    context.colors.primary,
                  ),
                ),
              )
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.spacing(2),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(
                        minWidth: context.spacing(36),
                        minHeight: context.spacing(36),
                      ),
                      iconSize: context.responsiveIconSize(32),
                      icon: Icon(
                        index < _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: context.colors.warning,
                      ),
                      onPressed: () =>
                          setState(() => _selectedRating = index + 1),
                    ),
                  );
                }),
              ),
            SizedBox(height: context.spacingMd),
            Text(
              _selectedRating > 0
                  ? '$_selectedRating Star${_selectedRating > 1 ? 's' : ''}'
                  : 'Tap to rate',
              style: context.typography.bodySmall!.copyWith(
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
          child: Text(
            AppStrings.cancel,
            style: context.typography.bodyMedium!,
          ),
        ),
        SizedBox(width: context.spacingSm),
        ElevatedButton(
          onPressed: (_selectedRating > 0 && !_isSubmitting) ? _submit : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.colors.primary,
            foregroundColor: context.colors.surface,
          ),
          child: Text(
            AppStrings.submit,
            style: context.typography.bodyMedium!,
          ),
        ),
      ],
    );
  }
}
