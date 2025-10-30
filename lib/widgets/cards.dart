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
    final responsivePadding = padding ?? context.responsivePadding(all: 16);
    final responsiveMargin = margin ?? EdgeInsets.symmetric(
      vertical: context.spacing(8),
    );
    final responsiveRadius = borderRadius ?? BorderRadius.circular(
      context.responsiveRadius(16),
    );

    Widget cardChild = Container(
      padding: responsivePadding,
      child: child,
    );

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: responsiveRadius,
        child: cardChild,
      );
    }

    return Card(
      color: color ?? MethodistTheme.white,
      elevation: elevation ?? context.responsive.cardElevation,
      margin: responsiveMargin,
      shape: RoundedRectangleBorder(borderRadius: responsiveRadius),
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
                    padding: context.responsivePadding(all: 8),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? MethodistTheme.mediumGray.withValues(alpha: 0.1)
                          : MethodistTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        context.responsiveRadius(8),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked
                          ? MethodistTheme.mediumGray
                          : MethodistTheme.primaryRed,
                      size: context.responsiveIconSize(20),
                    ),
                  ),
                  SizedBox(width: context.spacing(16)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.responsiveTitleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: context.spacing(4)),
                        Text(
                          subtitle!,
                          style: context.responsiveBodySmall.copyWith(
                            color: MethodistTheme.mediumGray,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                Flexible(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (trailing != null) ...[
                        trailing!,
                        if (isLocked || onTap != null)
                          SizedBox(width: context.spacing(8)),
                      ],
                      if (isLocked)
                        Container(
                          padding: context.responsivePadding(all: 8),
                          decoration: BoxDecoration(
                            color:
                            MethodistTheme.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveRadius(8),
                            ),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: MethodistTheme.errorRed,
                            size: context.responsiveIconSize(20),
                          ),
                        )
                      else if (onTap != null && trailing == null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: context.responsiveIconSize(16),
                          color: MethodistTheme.mediumGray,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              SizedBox(height: context.spacing(16)),
              Text(
                description!,
                style: context.responsiveBodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (isLocked) ...[
              SizedBox(height: context.spacing(8)),
              Container(
                padding: context.responsivePadding(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: MethodistTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.responsiveRadius(8),
                  ),
                  border: Border.all(
                    color:
                    MethodistTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: context.responsiveIconSize(14),
                      color: MethodistTheme.warningOrange,
                    ),
                    SizedBox(width: context.spacing(4)),
                    Flexible(
                      child: Text(
                        'Admin approval required',
                        style: context.responsiveBodySmall.copyWith(
                          color: MethodistTheme.warningOrange,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              SizedBox(height: context.spacing(16)),
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
            padding: context.responsivePadding(all: 24),
            decoration: BoxDecoration(
              color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(
                context.responsiveRadius(20),
              ),
            ),
            child: Icon(
              icon,
              size: context.responsiveIconSize(48),
              color: MethodistTheme.primaryRed,
            ),
          ),
          SizedBox(height: context.spacing(16)),
          Text(
            title,
            style: context.responsiveTitleLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null) ...[
            SizedBox(height: context.spacing(8)),
            Text(
              description!,
              style: context.responsiveBodyMedium.copyWith(
                color: MethodistTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
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
      debugPrint('Error checking user rating: $e');
      setState(() {
        isLoadingRating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = widget.dateTime.toLocal().toString().split(' ').first;
    final timeStr = DateFormat('hh:mm a').format(widget.dateTime);
    final dayOfWeek = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ][widget.dateTime.weekday - 1];

    return MethodistCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: context.responsivePadding(all: 8),
                decoration: BoxDecoration(
                  color: MethodistTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.responsiveRadius(8),
                  ),
                ),
                child: Icon(
                  Icons.event,
                  color: MethodistTheme.primaryRed,
                  size: context.responsiveIconSize(20),
                ),
              ),
              SizedBox(width: context.spacing(16)),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.responsiveTitleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacing(16)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: context.responsiveIconSize(16),
                  color: MethodistTheme.mediumGray,
                ),
                SizedBox(width: context.spacing(4)),
                Text(
                  '$dayOfWeek, $dateStr',
                  style: context.responsiveBodySmall,
                ),
                SizedBox(width: context.spacing(16)),
                Icon(
                  Icons.access_time,
                  size: context.responsiveIconSize(16),
                  color: MethodistTheme.mediumGray,
                ),
                SizedBox(width: context.spacing(4)),
                Text(
                  timeStr,
                  style: context.responsiveBodySmall,
                ),
              ],
            ),
          ),
          if (widget.venue != null) ...[
            SizedBox(height: context.spacing(8)),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: context.responsiveIconSize(16),
                  color: MethodistTheme.mediumGray,
                ),
                SizedBox(width: context.spacing(4)),
                Expanded(
                  child: Text(
                    widget.venue!,
                    style: context.responsiveBodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.spacing(8)),
          Text(
            widget.description,
            style: context.responsiveBodyMedium.copyWith(
              color: MethodistTheme.mediumGray,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.showRating) ...[
            Divider(height: context.spacing(24) * 2),
            if (isLoadingRating)
              Center(
                child: SizedBox(
                  height: context.responsiveIconSize(30),
                  width: context.responsiveIconSize(30),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      MethodistTheme.primaryRed,
                    ),
                  ),
                ),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  final isMobile = constraints.maxWidth < 300;

                  if (isMobile) {
                    return Column(
                      children: [
                        _buildAverageRatingSection(context),
                        SizedBox(height: context.spacing(12)),
                        _buildYourRatingSection(context),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(
                            child: _buildAverageRatingSection(context)),
                        SizedBox(width: context.spacing(12)),
                        Expanded(child: _buildYourRatingSection(context)),
                      ],
                    );
                  }
                },
              ),
          ],
        ],
      ),
    );
  }

  /// ✅ FIXED: Average Rating - Score under label properly aligned
  Widget _buildAverageRatingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Average Rating',
          style: context.responsiveBodySmall.copyWith(
            color: MethodistTheme.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.spacing(4)),
        Row(
          children: [
            Icon(
              Icons.star,
              size: context.responsiveIconSize(18),
              color: MethodistTheme.warningOrange,
            ),
            SizedBox(width: context.spacing(4)),
            Text(
              '${widget.avgRating.toStringAsFixed(1)}/5',
              style: context.responsiveBodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: MethodistTheme.warningOrange,
              ),
            ),
            SizedBox(width: context.spacing(4)),
            Flexible(
              child: Text(
                '(${widget.numRatings})',
                style: context.responsiveBodySmall.copyWith(
                  color: MethodistTheme.mediumGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// ✅ FIXED: Your Rating - Score under label properly aligned
  Widget _buildYourRatingSection(BuildContext context) {
    if (userRating != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            'Your Rating',
            style: context.responsiveBodySmall.copyWith(
              color: MethodistTheme.mediumGray,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacing(4)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.star,
                size: context.responsiveIconSize(18),
                color: MethodistTheme.warningOrange,
              ),
              SizedBox(width: context.spacing(4)),
              Text(
                '$userRating/5',
                style: context.responsiveBodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MethodistTheme.warningOrange,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => _showRatingDialog(context),
        icon: Icon(
          Icons.star_rate,
          size: context.responsiveIconSize(16),
        ),
        label: Text(
          'Rate',
          style: TextStyle(
            fontSize: context.responsiveFontSize(14),
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: MethodistTheme.primaryRed,
          foregroundColor: MethodistTheme.white,
          padding: context.responsivePadding(
            horizontal: 12,
            vertical: 8,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.responsiveRadius(8),
            ),
          ),
        ),
      );
    }
  }

  Future<void> _showRatingDialog(BuildContext context) async {
    int selectedRating = 0;
    bool isSubmitting = false;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'Rate Event',
            style: context.responsiveHeadlineSmall,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How would you rate "${widget.title}"?',
                  style: context.responsiveBodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: context.spacing(24)),
                if (isSubmitting)
                  SizedBox(
                    height: context.responsiveIconSize(40),
                    width: context.responsiveIconSize(40),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        MethodistTheme.primaryRed,
                      ),
                    ),
                  )
                else
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating
                                ? Icons.star
                                : Icons.star_border,
                            color: MethodistTheme.warningOrange,
                            size: context.responsiveIconSize(40),
                          ),
                          onPressed: () {
                            setDialogState(() {
                              selectedRating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSubmitting ? null : () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                ),
              ),
            ),
            SizedBox(width: context.spacing(8)),
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
              child: Text(
                'Submit',
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

      final permissions =
          (userData['permissions'] as List?)?.cast<String>() ?? [];

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
        final freshEventSnapshot = await transaction.get(eventRef);

        if (!freshEventSnapshot.exists) {
          throw Exception('Event document was deleted during transaction');
        }

        final eventData = freshEventSnapshot.data();
        final oldAvgRating =
        _safeToDouble(eventData?['avgRating'], 0.0);
        final oldCount =
        _safeToInt(eventData?['ratingCount'], 0);

        final newCount = oldCount + 1;
        final newAvgRating =
            (oldAvgRating * oldCount + rating) / newCount;

        transaction.update(eventRef, {
          'avgRating': newAvgRating,
          'ratingCount': newCount,
        });

        transaction.set(
          eventRef.collection('ratings').doc(user.uid),
          {
            'userId': user.uid,
            'rating': rating,
            'timestamp': FieldValue.serverTimestamp(),
          },
        );
      });

      setState(() {
        userRating = rating;
      });

      if (context.mounted) {
        MethodistTheme.showSuccessSnackBar(
          context,
          'Thank you for rating this event!',
        );
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
      if (context.mounted) {
        MethodistTheme.showErrorSnackBar(
          context,
          'Error submitting rating: $e',
        );
      }
    }
  }

  double _safeToDouble(dynamic value, double defaultValue) {
    try {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    } catch (e) {
      debugPrint('Error converting to double: $e');
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
      debugPrint('Error converting to int: $e');
      return defaultValue;
    }
  }
}
