import 'package:flutter/material.dart';
import '../app/theme.dart';

enum ButtonType { primary, secondary, text, danger }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final IconData? icon;
  final ButtonType type;
  final double? width;
  final double? height;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.type = ButtonType.primary,
    this.width,
    this.height,
  });

  const PrimaryButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.secondary;

  const PrimaryButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.text;

  const PrimaryButton.danger({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.icon,
    this.width,
    this.height,
  }) : type = ButtonType.danger;

  @override
  Widget build(BuildContext context) {
    // Get responsive sizing
    final responsiveIconSize = context.responsiveIconSize(20);
    final responsiveButtonHeight = context.responsiveIconSize(48);
    final responsiveSpacing = context.spacing(8);

    Widget buttonChild = loading
        ? SizedBox(
      width: responsiveIconSize,
      height: responsiveIconSize,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(
          type == ButtonType.secondary || type == ButtonType.text
              ? MethodistTheme.primaryRed
              : MethodistTheme.white,
        ),
      ),
    )
        : Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: responsiveIconSize),
          SizedBox(width: responsiveSpacing),
        ],
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.responsiveFontSize(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    // Define responsive button style
    ButtonStyle getResponsiveButtonStyle(ButtonStyle baseStyle) {
      return baseStyle.copyWith(
        padding: WidgetStateProperty.all(
          context.responsivePadding(
            horizontal: 24,
            vertical: 14,
          ),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              context.responsiveRadius(12),
            ),
          ),
        ),
      );
    }

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(MethodistTheme.primaryButtonStyle),
          child: buttonChild,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(MethodistTheme.secondaryButtonStyle),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(MethodistTheme.textButtonStyle),
          child: buttonChild,
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(MethodistTheme.dangerButtonStyle),
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? responsiveButtonHeight,
      child: button,
    );
  }
}
