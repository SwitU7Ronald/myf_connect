// lib/widgets/cards.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../app/theme.dart';

class MethodistCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const MethodistCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.color,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardChild = Container(
      padding: padding ?? MethodistTheme.paddingM,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: borderRadius ?? BorderRadius.circular(MethodistTheme.radiusL),
        child: cardChild,
      );
    }

    return Card(
      color: color ?? MethodistTheme.white,
      elevation: elevation ?? 2,
      margin: margin ?? MethodistTheme.marginS,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(MethodistTheme.radiusL),
      ),
      child: cardChild,
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? description;
  final IconData? icon;
  final VoidCallback? onTap;
  final List<Widget>? actions;
  final bool isLocked;
  final Widget? trailing;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.onTap,
    this.actions,
    this.isLocked = false,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return MethodistCard(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Container(
                    padding: MethodistTheme.paddingS,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? MethodistTheme.mediumGray.withValues(alpha: 0.1)
                          : MethodistTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked
                          ? MethodistTheme.mediumGray
                          : MethodistTheme.primaryRed,
                      size: 20,
                    ),
                  ),
                  SizedBox(width: MethodistTheme.spacingM),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: MethodistTheme.titleMedium),
                      if (subtitle != null) ...[
                        SizedBox(height: MethodistTheme.spacingXS),
                        Text(
                          subtitle!,
                          style: MethodistTheme.bodySmall.copyWith(
                            color: MethodistTheme.mediumGray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (trailing != null) ...[
                      trailing!,
                      if (isLocked || onTap != null)
                        SizedBox(width: MethodistTheme.spacingS),
                    ],
                    if (isLocked)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: MethodistTheme.errorRed.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: MethodistTheme.errorRed,
                          size: 20,
                        ),
                      )
                    else if (onTap != null && trailing == null)
                      const Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: MethodistTheme.mediumGray,
                      ),
                  ],
                ),
              ],
            ),
            if (description != null) ...[
              SizedBox(height: MethodistTheme.spacingM),
              Text(
                description!,
                style: MethodistTheme.bodyMedium,
              ),
            ],
            if (isLocked) ...[
              SizedBox(height: MethodistTheme.spacingS),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: MethodistTheme.spacingS,
                  vertical: MethodistTheme.spacingXS,
                ),
                decoration: BoxDecoration(
                  color: MethodistTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                  border: Border.all(
                    color: MethodistTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 14,
                      color: MethodistTheme.warningOrange,
                    ),
                    SizedBox(width: MethodistTheme.spacingXS),
                    Text(
                      'Admin approval required',
                      style: MethodistTheme.bodySmall.copyWith(
                        color: MethodistTheme.warningOrange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: MethodistTheme.spacingM),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions!,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  final String title;
  final String? description;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureCard({
    super.key,
    required this.title,
    this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return MethodistCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: MethodistTheme.paddingL,
            decoration: BoxDecoration(
              color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(MethodistTheme.radiusXL),
            ),
            child: Icon(
              icon,
              size: 48,
              color: MethodistTheme.primaryRed,
            ),
          ),
          SizedBox(height: MethodistTheme.spacingM),
          Text(
            title,
            style: MethodistTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          if (description != null) ...[
            SizedBox(height: MethodistTheme.spacingS),
            Text(
              description!,
              style: MethodistTheme.bodyMedium.copyWith(
                color: MethodistTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}


class EventCard extends StatefulWidget {
  final String title;
  final String description;
  final DateTime dateTime;
  final String? venue;
  final VoidCallback? onTap;
  final bool showRating;
  final double avgRating;
  final int numRatings;
  final String eventId;
  final String campOrMyfId;
  final bool isCamp;

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateTime,
    this.venue,
    this.onTap,
    this.showRating = false,
    this.avgRating = 0.0,
    this.numRatings = 0,
    required this.eventId,
    required this.campOrMyfId,
    this.isCamp = true,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  int? userRating;
  bool isLoadingRating = true;

  @override
  void initState() {
    super.initState();
    _checkUserRating();
  }

  Future<void> _checkUserRating() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || !widget.showRating) {
        setState(() {
          isLoadingRating = false;
        });
        return;
      }
      final collection = widget.isCamp ? 'camps' : 'myfs';
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.campOrMyfId)
          .collection('events')
          .doc(widget.eventId)
          .collection('ratings')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        final rating = ratingsSnapshot.docs.first.data()['rating'] as int;
        setState(() {
          userRating = rating;
        });
      }
      setState(() {
        isLoadingRating = false;
      });
    } catch (e) {
      setState(() {
        isLoadingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.dateTime.toLocal().toString().split(' ').first;
    final timeStr = DateFormat('hh:mm a').format(widget.dateTime);
    final dayOfWeek =
    ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][widget.dateTime.weekday - 1];

    return MethodistCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: MethodistTheme.paddingS,
                decoration: BoxDecoration(
                  color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                ),
                child: const Icon(
                  Icons.event,
                  color: MethodistTheme.primaryRed,
                  size: 20,
                ),
              ),
              SizedBox(width: MethodistTheme.spacingM),
              Expanded(
                child: Text(widget.title, style: MethodistTheme.titleMedium),
              ),
            ],
          ),
          SizedBox(height: MethodistTheme.spacingM),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 16, color: MethodistTheme.mediumGray),
              SizedBox(width: MethodistTheme.spacingXS),
              Text('$dayOfWeek, $dateStr', style: MethodistTheme.bodySmall),
              SizedBox(width: MethodistTheme.spacingM),
              const Icon(Icons.access_time, size: 16, color: MethodistTheme.mediumGray),
              SizedBox(width: MethodistTheme.spacingXS),
              Text(timeStr, style: MethodistTheme.bodySmall),
            ],
          ),
          if (widget.venue != null) ...[
            SizedBox(height: MethodistTheme.spacingS),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: MethodistTheme.mediumGray),
                SizedBox(width: MethodistTheme.spacingXS),
                Expanded(child: Text(widget.venue!, style: MethodistTheme.bodySmall)),
              ],
            ),
          ],
          SizedBox(height: MethodistTheme.spacingS),
          Text(
            widget.description,
            style: MethodistTheme.bodyMedium.copyWith(color: MethodistTheme.mediumGray),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.showRating) ...[
            Divider(height: MethodistTheme.spacingL * 2),
            if (isLoadingRating)
              Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(MethodistTheme.primaryRed),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    // -- Average Rating LEFT side --
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Average Rating',
                          style: MethodistTheme.bodySmall.copyWith(
                            color: MethodistTheme.mediumGray,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: MethodistTheme.spacingXS),
                        Row(
                          children: [
                            Icon(Icons.star, size: 18, color: MethodistTheme.warningOrange),
                            SizedBox(width: MethodistTheme.spacingXS),
                            Text(
                              '${widget.avgRating.toStringAsFixed(1)}/5',
                              style: MethodistTheme.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                                color: MethodistTheme.warningOrange,
                              ),
                            ),
                            SizedBox(width: MethodistTheme.spacingXS),
                            Text(
                              '(${widget.numRatings})',
                              style: MethodistTheme.bodySmall.copyWith(
                                color: MethodistTheme.mediumGray,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    Spacer(),

                    // -- Your Rating or Button RIGHT side. EXACT SAME STYLE AS LEFT --
                    if (userRating != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Your Rating',
                            style: MethodistTheme.bodySmall.copyWith(
                              color: MethodistTheme.mediumGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: MethodistTheme.spacingXS),
                          Row(
                            children: [
                              Icon(Icons.star, size: 18, color: MethodistTheme.warningOrange),
                              SizedBox(width: MethodistTheme.spacingXS),
                              Text(
                                '$userRating/5',
                                style: MethodistTheme.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: MethodistTheme.warningOrange,
                                ),
                              ),
                            ],
                          ),
                        ],
                      )
                    else
                      ElevatedButton.icon(
                        onPressed: () => _showRatingDialog(context),
                        icon: const Icon(Icons.star_rate, size: 16),
                        label: const Text('Rate'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: MethodistTheme.primaryRed,
                          foregroundColor: MethodistTheme.white,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _showRatingDialog(BuildContext context) async {
    int selectedRating = 0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Rate Event', style: MethodistTheme.headlineSmall),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How would you rate "${widget.title}"?',
                style: MethodistTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: MethodistTheme.spacingL),
              if (isSubmitting)
                const CircularProgressIndicator()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < selectedRating ? Icons.star : Icons.star_border,
                        color: MethodistTheme.warningOrange,
                        size: 40,
                      ),
                      onPressed: () {
                        setDialogState(() {
                          selectedRating = index + 1;
                        });
                      },
                    );
                  }),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            SizedBox(width: MethodistTheme.spacingS),
            ElevatedButton(
              onPressed: (selectedRating > 0 && !isSubmitting)
                  ? () async {
                setDialogState(() {
                  isSubmitting = true;
                });
                await _submitRating(context, selectedRating);
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: MethodistTheme.primaryRed,
                foregroundColor: MethodistTheme.white,
              ),
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  double _safeToDouble(dynamic value, double defaultValue) {
    try {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  int _safeToInt(dynamic value, int defaultValue) {
    try {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is double) return value.toInt();
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      return defaultValue;
    }
  }

  Future<void> _submitRating(BuildContext context, int rating) async {
    try {
      if (rating < 1 || rating > 5) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'Invalid rating value. Rating must be between 1 and 5.',
          );
        }
        return;
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'Please sign in to rate events',
          );
        }
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'User profile not found. Please complete your profile first.',
          );
        }
        return;
      }

      final userData = userDoc.data();
      if (userData == null) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'User data is empty. Please complete your profile.',
          );
        }
        return;
      }

      final permissions = (userData['permissions'] as List?)?.cast<String>() ?? [];
      final userName =
      '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim();

      if (!permissions.contains(widget.campOrMyfId)) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'You do not have permission to rate events in this ${widget.isCamp ? 'camp' : 'MYF'}.',
          );
        }
        return;
      }

      final collection = widget.isCamp ? 'camps' : 'myfs';
      final eventRef = FirebaseFirestore.instance
          .collection(collection)
          .doc(widget.campOrMyfId)
          .collection('events')
          .doc(widget.eventId);

      final eventSnapshot = await eventRef.get();
      if (!eventSnapshot.exists) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'Event not found. It may have been deleted.',
          );
        }
        return;
      }

      final ratingsSnapshot = await eventRef
          .collection('ratings')
          .where('userId', isEqualTo: user.uid)
          .limit(1)
          .get();

      if (ratingsSnapshot.docs.isNotEmpty) {
        if (context.mounted) {
          MethodistTheme.showErrorSnackBar(
            context,
            'You have already rated this event.',
          );
        }
        return;
      }

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists) {
          throw Exception('Event document was deleted during transaction');
        }

        final eventData = eventSnapshot.data()!;
        final currentAvgRating = _safeToDouble(eventData['avgRating'], 0.0);
        final currentNumRatings = _safeToInt(eventData['numRatings'], 0);

        final newNumRatings = currentNumRatings + 1;
        final oldRatingTotal = currentAvgRating * currentNumRatings;
        final newAvgRating = (oldRatingTotal + rating) / newNumRatings;

        final ratingRef = eventRef.collection('ratings').doc();
        transaction.set(ratingRef, {
          'userId': user.uid,
          'userName': userName.isEmpty ? 'Anonymous' : userName,
          'rating': rating,
          'timestamp': FieldValue.serverTimestamp(),
        });

        transaction.update(eventRef, {
          'avgRating': newAvgRating,
          'numRatings': newNumRatings,
        });
      });

      await _checkUserRating();

      if (context.mounted) {
        MethodistTheme.showSuccessSnackBar(
          context,
          'Thank you for rating this event!',
        );
      }
    } catch (e) {
      if (context.mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Error submitting rating: ${e.toString()}',
        );
      }
    }
  }
}
