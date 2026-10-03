import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/locator/locator.dart' as di;
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/services/auth/auth_repository.dart';
import 'package:myf_connect/features/events/data/repositories/event_repository.dart';
import 'package:myf_connect/core/widgets/event_rating_dialog.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


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
                padding: EdgeInsets.all(context.spacingSm),
                decoration: BoxDecoration(
                  color: context.colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.radiusSm.topLeft.x,
                  ),
                ),
                child: Icon(
                  Icons.event,
                  color: context.colors.primary,
                  size: context.responsiveIconSize(20),
                ),
              ),
              SizedBox(width: context.spacingMd),
              Expanded(
                child: Text(
                  widget.title,
                  style: context.typography.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: context.spacingMd),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: context.responsiveIconSize(16),
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: context.spacingXs),
                Text(
                  '$dayOfWeek, $dateStr',
                  style: context.typography.bodySmall,
                ),
                SizedBox(width: context.spacingMd),
                Icon(
                  Icons.access_time,
                  size: context.responsiveIconSize(16),
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: context.spacingXs),
                Text(timeStr, style: context.typography.bodySmall),
              ],
            ),
          ),
          if (widget.venue != null) ...[
            SizedBox(height: context.spacingSm),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: context.responsiveIconSize(16),
                  color: context.colors.textSecondary,
                ),
                SizedBox(width: context.spacingXs),
                Expanded(
                  child: Text(
                    widget.venue!,
                    style: context.typography.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: context.spacingSm),
          Text(
            widget.description,
            style: context.typography.bodyMedium!.copyWith(
              color: context.colors.textSecondary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (widget.showRating) ...[
            Divider(height: context.spacingLg * 2),
            if (isLoadingRating)
              Center(
                child: SizedBox(
                  height: context.responsiveIconSize(30),
                  width: context.responsiveIconSize(30),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.colors.primary,
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
                        SizedBox(height: context.spacingMd),
                        _buildYourRatingSection(context),
                      ],
                    );
                  } else {
                    return Row(
                      children: [
                        Expanded(child: _buildAverageRatingSection(context)),
                        SizedBox(width: context.spacingMd),
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
          style: context.typography.bodySmall!.copyWith(
            color: context.colors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: context.spacingXs),
        Row(
          children: [
            Icon(
              Icons.star,
              size: context.responsiveIconSize(18),
              color: context.colors.warning,
            ),
            SizedBox(width: context.spacingXs),
            Text(
              '${widget.avgRating.toStringAsFixed(1)}/5',
              style: context.typography.bodySmall!.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colors.warning,
              ),
            ),
            SizedBox(width: context.spacingXs),
            Flexible(
              child: Text(
                '(${widget.numRatings})',
                style: context.typography.bodySmall!.copyWith(
                  color: context.colors.textSecondary,
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
            style: context.typography.bodySmall!.copyWith(
              color: context.colors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: context.spacingXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Icon(
                Icons.star,
                size: context.responsiveIconSize(18),
                color: context.colors.warning,
              ),
              SizedBox(width: context.spacingXs),
              Text(
                '$userRating/5',
                style: context.typography.bodySmall!.copyWith(
                  fontWeight: FontWeight.w600,
                  color: context.colors.warning,
                ),
              ),
            ],
          ),
        ],
      );
    } else {
      return SizedBox(
        height: context.spacing(36),
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
          icon: Icon(
            Icons.star_border,
            size: context.responsiveIconSize(18),
            color: context.colors.primary,
          ),
          label: Text(
            AppStrings.rateEvent,
            style: context.typography.bodyMedium!.copyWith(
              fontSize: context.responsiveFontSize(14),
              color: context.colors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: context.colors.primary,
            side: BorderSide(color: context.colors.primary, width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: context.radiusSm,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: context.spacingMd,
              vertical: context.spacingSm,
            ),
          ),
        ),
      );
    }
  }
}
