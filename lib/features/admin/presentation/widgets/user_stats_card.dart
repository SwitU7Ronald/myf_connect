import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';

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
      margin: context.responsivePadding(horizontal: 16, vertical: 8),
      padding: context.responsivePadding(all: 16),
      color: MyfTheme.primaryRed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total Users',
                style: context.responsiveBodySmall.copyWith(
                  color: MyfTheme.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                '$total',
                style: context.responsiveHeadlineMedium.copyWith(
                  color: MyfTheme.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          if (hasFilters)
            Container(
              padding: context.responsivePadding(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: MyfTheme.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(20),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.filter_alt,
                    color: MyfTheme.white,
                    size: context.responsiveIconSize(16),
                  ),
                  SizedBox(width: context.spacing(4)),
                  Text(
                    'Filtered: $filtered',
                    style: context.responsiveBodyMedium.copyWith(
                      color: MyfTheme.white,
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
