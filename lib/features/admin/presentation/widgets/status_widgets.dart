import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


enum StatusType { success, warning, error, info, neutral }

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusType type;
  final bool isSmall;

  const StatusBadge({
    super.key,
    required this.text,
    required this.type,
    this.isSmall = false,
  });

  const StatusBadge.success({
    super.key,
    required this.text,
    this.isSmall = false,
  }) : type = StatusType.success;

  const StatusBadge.warning({
    super.key,
    required this.text,
    this.isSmall = false,
  }) : type = StatusType.warning;

  const StatusBadge.error({super.key, required this.text, this.isSmall = false})
    : type = StatusType.error;

  const StatusBadge.info({super.key, required this.text, this.isSmall = false})
    : type = StatusType.info;

  const StatusBadge.neutral({
    super.key,
    required this.text,
    this.isSmall = false,
  }) : type = StatusType.neutral;

  Color backgroundColor(BuildContext context) {
    switch (type) {
      case StatusType.success:
        return context.colors.success;
      case StatusType.warning:
        return context.colors.warning;
      case StatusType.error:
        return context.colors.error;
      case StatusType.info:
        return context.colors.info;
      case StatusType.neutral:
        return context.colors.textSecondary;
    }
  }

  IconData? get icon {
    switch (type) {
      case StatusType.success:
        return Icons.check_circle;
      case StatusType.warning:
        return Icons.warning;
      case StatusType.error:
        return Icons.error;
      case StatusType.info:
        return Icons.info;
      case StatusType.neutral:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? context.spacingSm : context.spacingMd,
        vertical: isSmall ? context.spacingXs : context.spacingSm,
      ),
      decoration: BoxDecoration(
        color: backgroundColor(context),
        borderRadius: BorderRadius.circular(
          isSmall ? MyfTheme.radiusS : MyfTheme.radiusM,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 12 : 14, color: context.colors.surface),
            SizedBox(width: context.spacingXs),
          ],
          Text(
            text,
            style: context.typography.bodyMedium?.copyWith(
              color: context.colors.surface,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class PermissionChip extends StatelessWidget {
  final String text;
  final bool isSelected;
  final ValueChanged<bool>? onChanged;

  const PermissionChip({
    super.key,
    required this.text,
    required this.isSelected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(text),
      selected: isSelected,
      onSelected: onChanged,
      selectedColor: context.colors.primary,
      backgroundColor: context.colors.background,
      labelStyle: context.typography.titleMedium,
      shape: RoundedRectangleBorder(
        borderRadius: context.radiusMd,
      ),
    );
  }
}

class CountBadge extends StatelessWidget {
  final int count;
  final Color? backgroundColor;
  final Color? textColor;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingSm,
        vertical: context.spacingXs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? context.colors.primary,
        borderRadius: context.radiusMd,
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: context.typography.bodyMedium?.copyWith(
          color: textColor ?? context.colors.surface,
          fontSize: context.responsiveFontSize(10),
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class ProgressCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double progress;
  final String? progressText;
  final Color? progressColor;

  const ProgressCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.progress,
    this.progressText,
    this.progressColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(context.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: context.typography.titleMedium!),
            if (subtitle != null) ...[
              SizedBox(height: context.spacingXs),
              Text(
                subtitle!,
                style: context.typography.bodySmall!.copyWith(
                  color: context.colors.textSecondary,
                ),
              ),
            ],
            SizedBox(height: context.spacingMd),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: context.colors.background,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? context.colors.primary,
              ),
            ),
            if (progressText != null) ...[
              SizedBox(height: context.spacingSm),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  progressText!,
                  style: context.typography.bodySmall!.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
