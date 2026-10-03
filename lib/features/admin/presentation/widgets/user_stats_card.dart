import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class UserStatsCard extends StatelessWidget {
  final int total;
  final int filtered;
  final bool hasFilters;

  const UserStatsCard({
    super.key,
    required this.total,
    required this.filtered,
    required this.hasFilters,
  });

  @override
  Widget build(BuildContext context) {
    return MyfCard(
      margin: EdgeInsets.symmetric(horizontal: context.spacingMd, vertical: context.spacingSm),
      padding: EdgeInsets.all(context.spacingMd),
      color: context.colors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Users',
                style: context.typography.bodySmall!.copyWith(
                  color: context.colors.surface.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '$total',
                style: context.typography.headlineMedium!.copyWith(
                  color: context.colors.surface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (hasFilters)
            Container(
              padding: context.responsivePadding(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: context.colors.surface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  context.radiusXl.topLeft.x,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: context.colors.surface,
                    size: context.responsiveIconSize(16),
                  ),
                  SizedBox(width: context.spacingXs),
                  Text(
                    'Filtered: $filtered',
                    style: context.typography.bodyMedium!.copyWith(
                      color: context.colors.surface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
