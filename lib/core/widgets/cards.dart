import 'package:flutter/material.dart';
import 'package:myf_connect/core/themes/theme.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/constants/app_strings.dart';

class MyfCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final Color? color;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const MyfCard({
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
    final responsiveMargin =
        margin ?? EdgeInsets.symmetric(vertical: context.spacing(8));
    final responsiveRadius =
        borderRadius ?? BorderRadius.circular(context.responsiveRadius(16));

    Widget cardChild = Container(padding: responsivePadding, child: child);

    if (onTap != null) {
      cardChild = InkWell(
        onTap: onTap,
        borderRadius: responsiveRadius,
        child: cardChild,
      );
    }

    return Card(
      color: color ?? MyfTheme.white,
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
    return MyfCard(
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
                          ? MyfTheme.mediumGray.withValues(alpha: 0.1)
                          : MyfTheme.primaryRed.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        context.responsiveRadius(8),
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked
                          ? MyfTheme.mediumGray
                          : MyfTheme.primaryRed,
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
                            color: MyfTheme.mediumGray,
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
                            color: MyfTheme.errorRed.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.responsiveRadius(8),
                            ),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: MyfTheme.errorRed,
                            size: context.responsiveIconSize(20),
                          ),
                        )
                      else if (onTap != null && trailing == null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: context.responsiveIconSize(16),
                          color: MyfTheme.mediumGray,
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
                padding: context.responsivePadding(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: MyfTheme.warningOrange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.responsiveRadius(8),
                  ),
                  border: Border.all(
                    color: MyfTheme.warningOrange.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: context.responsiveIconSize(14),
                      color: MyfTheme.warningOrange,
                    ),
                    SizedBox(width: context.spacing(4)),
                    Flexible(
                      child: Text(
                        AppStrings.adminApprovalRequired,
                        style: context.responsiveBodySmall.copyWith(
                          color: MyfTheme.warningOrange,
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
              Row(mainAxisAlignment: MainAxisAlignment.end, children: actions!),
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
    return MyfCard(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: context.responsivePadding(all: 24),
            decoration: BoxDecoration(
              color: MyfTheme.primaryRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(context.responsiveRadius(20)),
            ),
            child: Icon(
              icon,
              size: context.responsiveIconSize(48),
              color: MyfTheme.primaryRed,
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
                color: MyfTheme.mediumGray,
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

