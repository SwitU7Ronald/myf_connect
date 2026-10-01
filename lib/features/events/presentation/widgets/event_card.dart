import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/features/auth/data/repositories/auth_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/features/events/presentation/widgets/event_rating_dialog.dart';

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
      final user = di.sl<AuthRepository>().currentUser;
      if (user == null || !widget.showRating) {
        setState(() {
          isLoadingRating = false;
        });
        return;
      }
      final collection = widget.isCamp ? 'camps' : 'myfs';

      final rating = await di.sl<EventRepository>().getUserRating(
        collection: collection,
        parentId: widget.campOrMyfId,
        eventId: widget.eventId,
        userId: user.uid,
      );

      if (rating != null) {
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
      'Sun',
    ][widget.dateTime.weekday - 1];

    return MyfCard(
      onTap: widget.onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: context.responsivePadding(all: 8),
                decoration: BoxDecoration(
                  color: MyfTheme.primaryRed.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.responsiveRadius(8),
                  ),
                ),
                child: Icon(
                  Icons.event,
                  color: MyfTheme.primaryRed,
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
                  color: MyfTheme.mediumGray,
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
                  color: MyfTheme.mediumGray,
                ),
                SizedBox(width: context.spacing(4)),
                Text(timeStr, style: context.responsiveBodySmall),
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
                  color: MyfTheme.mediumGray,
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
              color: MyfTheme.mediumGray,
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
                      MyfTheme.primaryRed,
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
                        Expanded(child: _buildAverageRatingSection(context)),
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

  Widget _buildAverageRatingSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.averageRating,
          style: context.responsiveBodySmall.copyWith(
            color: MyfTheme.mediumGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.spacing(4)),
        Row(
          children: [
            Icon(
              Icons.star,
              size: context.responsiveIconSize(18),
              color: MyfTheme.warningOrange,
            ),
            SizedBox(width: context.spacing(4)),
            Text(
              '${widget.avgRating.toStringAsFixed(1)}/5',
              style: context.responsiveBodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: MyfTheme.warningOrange,
              ),
            ),
            SizedBox(width: context.spacing(4)),
            Flexible(
              child: Text(
                '(${widget.numRatings})',
                style: context.responsiveBodySmall.copyWith(
                  color: MyfTheme.mediumGray,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildYourRatingSection(BuildContext context) {
    if (userRating != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            AppStrings.yourRating,
            style: context.responsiveBodySmall.copyWith(
              color: MyfTheme.mediumGray,
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
                color: MyfTheme.warningOrange,
              ),
              SizedBox(width: context.spacing(4)),
              Text(
                '$userRating/5',
                style: context.responsiveBodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: MyfTheme.warningOrange,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox(
        height: 36,
        child: OutlinedButton.icon(
          onPressed: () => EventRatingDialog.show(
            context: context,
            eventId: widget.eventId,
            campOrMyfId: widget.campOrMyfId,
            eventTitle: widget.title,
            isCamp: widget.isCamp,
            onRatingSubmitted: (rating) {
              setState(() => userRating = rating);
            },
          ),
          icon: Icon(Icons.star_border, size: 18, color: MyfTheme.primaryRed),
          label: Text(
            AppStrings.rateEvent,
            style: TextStyle(
              fontSize: 14,
              color: MyfTheme.primaryRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: MyfTheme.primaryRed,
            side: BorderSide(color: MyfTheme.primaryRed, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.spacing(16),
              vertical: context.spacing(6),
            ),
          ),
        ),
      );
    }
  }
}
