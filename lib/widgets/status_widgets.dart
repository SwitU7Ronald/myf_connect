import 'package:flutter/material.dart';
import '../app/theme.dart';

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
        return MethodistTheme.successGreen;
      case StatusType.warning:
        return MethodistTheme.warningOrange;
      case StatusType.error:
        return MethodistTheme.errorRed;
      case StatusType.info:
        return MethodistTheme.infoBlue;
      case StatusType.neutral:
        return MethodistTheme.mediumGray;
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
        horizontal: isSmall ? MethodistTheme.spacingS : MethodistTheme.spacingM,
        vertical: isSmall ? MethodistTheme.spacingXS : MethodistTheme.spacingS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(
          isSmall ? MethodistTheme.radiusS : MethodistTheme.radiusM,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: isSmall ? 12 : 14, color: MethodistTheme.white),
            SizedBox(width: MethodistTheme.spacingXS),
          ],
          Text(
            text,
            style: TextStyle(
              color: MethodistTheme.white,
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
      selectedColor: MethodistTheme.primaryRed,
      backgroundColor: MethodistTheme.lightGray,
      labelStyle: TextStyle(
        color: isSelected ? MethodistTheme.white : MethodistTheme.darkGray,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
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
        horizontal: MethodistTheme.spacingS,
        vertical: MethodistTheme.spacingXS,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? MethodistTheme.primaryRed,
        borderRadius: BorderRadius.circular(MethodistTheme.radiusM),
      ),
      constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: TextStyle(
          color: textColor ?? MethodistTheme.white,
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
        padding: MethodistTheme.paddingM,
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
            SizedBox(height: MethodistTheme.spacingM),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: MethodistTheme.lightGray,
              valueColor: AlwaysStoppedAnimation<Color>(
                progressColor ?? MethodistTheme.primaryRed,
              ),
            ),
            if (progressText != null) ...[
              SizedBox(height: MethodistTheme.spacingS),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  progressText!,
                  style: MethodistTheme.bodySmall.copyWith(
                    color: MethodistTheme.mediumGray,
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
