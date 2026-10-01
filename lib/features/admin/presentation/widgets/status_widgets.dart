import 'package:flutter/material.dart';
import 'package:myf_connect/core/themes/theme.dart';

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

  Color get backgroundColor {
    switch (type) {
      case StatusType.success:
        return MyfTheme.successGreen;
      case StatusType.warning:
        return MyfTheme.warningOrange;
      case StatusType.error:
        return MyfTheme.errorRed;
      case StatusType.info:
        return MyfTheme.infoBlue;
      case StatusType.neutral:
        return MyfTheme.mediumGray;
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
        horizontal: isSmall ? MyfTheme.spacingS : MyfTheme.spacingM,
        vertical: isSmall ? MyfTheme.spacingXS : MyfTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          isSmall ? MyfTheme.radiusS : MyfTheme.radiusM,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 12 : 14, color: MyfTheme.white),
            SizedBox(width: MyfTheme.spacingXS),
          ],
          Text(
            text,
            style: TextStyle(
              color: MyfTheme.white,
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
      selectedColor: MyfTheme.primaryRed,
      backgroundColor: MyfTheme.lightGray,
      labelStyle: TextStyle(
        color: isSelected ? MyfTheme.white : MyfTheme.darkGray,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MyfTheme.radiusM),
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
      padding: const EdgeInsets.symmetric(
        horizontal: MyfTheme.spacingS,
        vertical: MyfTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? MyfTheme.primaryRed,
        borderRadius: BorderRadius.circular(MyfTheme.radiusM),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? MyfTheme.white,
          fontSize: 10,
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
        padding: MyfTheme.paddingM,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: MyfTheme.titleMedium),
            if (subtitle != null) ...[
              SizedBox(height: MyfTheme.spacingXS),
              Text(
                subtitle!,
                style: MyfTheme.bodySmall.copyWith(color: MyfTheme.mediumGray),
              ),
            ],
            SizedBox(height: MyfTheme.spacingM),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: MyfTheme.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? MyfTheme.primaryRed,
              ),
            ),
            if (progressText != null) ...[
              SizedBox(height: MyfTheme.spacingS),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  progressText!,
                  style: MyfTheme.bodySmall.copyWith(
                    color: MyfTheme.mediumGray,
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
