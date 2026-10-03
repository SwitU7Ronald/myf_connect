import 'package:flutter/material.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/constants/app_strings.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class MyfCard extends StatefulWidget {
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
  State<MyfCard> createState() => _MyfCardState();
}

class _MyfCardState extends State<MyfCard> {
  @override
  Widget build(BuildContext context) {
    final responsivePadding = widget.padding ?? EdgeInsets.all(context.spacingMd);
    final responsiveMargin =
        widget.margin ?? EdgeInsets.symmetric(vertical: context.spacingSm);
    final responsiveRadius =
        widget.borderRadius ?? context.radiusLg;

    Widget cardChild = Container(padding: responsivePadding, child: widget.child);

    if (widget.onTap != null) {
      cardChild = InkWell(
        onTap: widget.onTap,
        borderRadius: responsiveRadius,
        hoverColor: context.colors.primary.withValues(alpha: 0.05),
        child: cardChild,
      );
    }

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: LiquidGlassContainer(
        margin: responsiveMargin,
        borderRadius: responsiveRadius.topLeft.x,
        baseColor: widget.color,
        child: Material(
          color: Colors.transparent,
          borderRadius: responsiveRadius,
          clipBehavior: Clip.antiAlias,
          child: cardChild,
        ),
      ),
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
                    padding: EdgeInsets.all(context.spacingSm),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? context.colors.textSecondary.withValues(alpha: 0.1)
                          : context.colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(
                        context.radiusSm.topLeft.x,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: isLocked
                          ? context.colors.textSecondary
                          : context.colors.primary,
                      size: context.responsiveIconSize(20),
                    ),
                  ),
                  SizedBox(width: context.spacingMd),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: context.typography.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (subtitle != null) ...[
                        SizedBox(height: context.spacingXs),
                        Text(
                          subtitle!,
                          style: context.typography.bodySmall!.copyWith(
                            color: context.colors.textSecondary,
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
                          SizedBox(width: context.spacingSm),
                      ],
                      if (isLocked)
                        Container(
                          padding: EdgeInsets.all(context.spacingSm),
                          decoration: BoxDecoration(
                            color: context.colors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(
                              context.radiusSm.topLeft.x,
                            ),
                          ),
                          child: Icon(
                            Icons.lock_outline,
                            color: context.colors.error,
                            size: context.responsiveIconSize(20),
                          ),
                        )
                      else if (onTap != null && trailing == null)
                        Icon(
                          Icons.arrow_forward_ios,
                          size: context.responsiveIconSize(16),
                          color: context.colors.textSecondary,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (description != null) ...[
              SizedBox(height: context.spacingMd),
              Text(
                description!,
                style: context.typography.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (isLocked) ...[
              SizedBox(height: context.spacingSm),
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.spacingSm, vertical: context.spacingXs),
                decoration: BoxDecoration(
                  color: context.colors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(
                    context.radiusSm.topLeft.x,
                  ),
                  border: Border.all(
                    color: context.colors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: context.responsiveIconSize(14),
                      color: context.colors.warning,
                    ),
                    SizedBox(width: context.spacingXs),
                    Flexible(
                      child: Text(
                        AppStrings.adminApprovalRequired,
                        style: context.typography.bodySmall!.copyWith(
                          color: context.colors.warning,
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
              SizedBox(height: context.spacingMd),
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
            padding: EdgeInsets.all(context.spacingLg),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.1),
              borderRadius: context.radiusXl,
            ),
            child: Icon(
              icon,
              size: context.responsiveIconSize(48),
              color: context.colors.primary,
            ),
          ),
          SizedBox(height: context.spacingMd),
          Text(
            title,
            style: context.typography.titleLarge,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (description != null) ...[
            SizedBox(height: context.spacingSm),
            Text(
              description!,
              style: context.typography.bodyMedium!.copyWith(
                color: context.colors.textSecondary,
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
