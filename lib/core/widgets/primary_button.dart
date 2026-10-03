import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';
import 'package:myf_connect/core/widgets/app_buttons.dart';


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
    final responsiveIconSize = context.responsiveIconSize(20);
    final responsiveButtonHeight = context.responsiveIconSize(48);
    final responsiveSpacing = context.spacingSm;

    Widget buttonChild = loading
        ? SizedBox(
            width: responsiveIconSize,
            height: responsiveIconSize,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.secondary || type == ButtonType.text
                    ? context.colors.primary
                    : context.colors.surface,
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
                  style: context.typography.labelLarge!.copyWith(fontSize: context.responsiveFontSize(14)),
                ),
              ),
            ],
          );

    ButtonStyle getResponsiveButtonStyle(ButtonStyle baseStyle) {
      return baseStyle.copyWith(
        padding: WidgetStateProperty.all(
          context.responsivePadding(horizontal: 24, vertical: 16),
        ),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100), // Stadium-like pill buttons
          ),
        ),
        elevation: WidgetStateProperty.resolveWith<double>((states) {
          if (states.contains(WidgetState.hovered)) return 6;
          if (states.contains(WidgetState.pressed)) return 2;
          return type == ButtonType.primary ? 4 : 0;
        }),
      );
    }

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(AppButtons.primary(context)),
          child: buttonChild,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(AppButtons.secondary(context)),
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(AppButtons.text(context)),
          child: buttonChild,
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: getResponsiveButtonStyle(AppButtons.danger(context)),
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
