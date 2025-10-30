import 'package:flutter/material.dart';
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
  final bool isLocked; // NEW: Add lock parameter

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.description,
    this.icon,
    this.onTap,
    this.actions,
    this.isLocked = false, // NEW: Default to false
  });

  @override
  Widget build(BuildContext context) {
    return MethodistCard(
      onTap: onTap,
      child: Opacity(
        opacity: isLocked ? 0.6 : 1.0, // NEW: Reduce opacity for locked items
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
                      color: isLocked // NEW: Change color for locked items
                          ? MethodistTheme.mediumGray.withValues(alpha: 0.1)
                          : MethodistTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked // NEW: Change icon color for locked items
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
                // NEW: Show lock icon or arrow based on lock status
                if (isLocked)
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: MethodistTheme.errorRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(MethodistTheme.radiusS),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      color: MethodistTheme.errorRed,
                      size: 20,
                    ),
                  )
                else if (onTap != null)
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: MethodistTheme.mediumGray,
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
            // NEW: Show warning badge for locked items
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
                    Icon(
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

class EventCard extends StatelessWidget {
  final String title;
  final String description;
  final DateTime dateTime;
  final String? venue;
  final VoidCallback? onTap;
  final bool showRating;
  final int? rating;
  final ValueChanged<int>? onRatingChanged;

  const EventCard({
    super.key,
    required this.title,
    required this.description,
    required this.dateTime,
    this.venue,
    this.onTap,
    this.showRating = false,
    this.rating,
    this.onRatingChanged,
  });

  String get dayOfWeek =>
      ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dateTime.weekday - 1];

  @override
  Widget build(BuildContext context) {
    final dateStr = dateTime.toLocal().toString().split(' ');
    final date = dateStr.first;
    final time = dateStr.length > 1 ? dateStr[1].substring(0, 5) : '';

    return MethodistCard(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: MethodistTheme.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: MethodistTheme.spacingS),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: MethodistTheme.mediumGray,
              ),
              SizedBox(width: MethodistTheme.spacingXS),
              Text('$dayOfWeek, $date'),
              if (time.isNotEmpty) ...[
                SizedBox(width: MethodistTheme.spacingM),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: MethodistTheme.mediumGray,
                ),
                SizedBox(width: MethodistTheme.spacingXS),
                Text(time),
              ],
            ],
          ),
          if (venue != null) ...[
            SizedBox(height: MethodistTheme.spacingXS),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: MethodistTheme.mediumGray,
                ),
                SizedBox(width: MethodistTheme.spacingXS),
                Expanded(child: Text(venue!)),
              ],
            ),
          ],
          if (description.isNotEmpty) ...[
            SizedBox(height: MethodistTheme.spacingS),
            Text(
              description,
              style: MethodistTheme.bodyMedium.copyWith(
                color: MethodistTheme.mediumGray,
              ),
            ),
          ],
          if (showRating) ...[
            SizedBox(height: MethodistTheme.spacingM),
            Row(
              children: [
                Text(
                  'Rate this event: ',
                  style: MethodistTheme.bodySmall,
                ),
                Expanded(
                  child: Row(
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () => onRatingChanged?.call(index + 1),
                        child: Icon(
                          index < (rating ?? 0) ? Icons.star : Icons.star_border,
                          color: MethodistTheme.warningOrange,
                          size: 20,
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}