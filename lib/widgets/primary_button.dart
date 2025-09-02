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
    Widget buttonChild = Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                type == ButtonType.secondary || type == ButtonType.text
                    ? MethodistTheme.primaryRed
                    : MethodistTheme.white,
              ),
            ),
          )
        else ...[
          if (icon != null) ...[
            Icon(icon, size: 18),
            SizedBox(width: MethodistTheme.spacingS),
          ],
          Text(label),
        ],
      ],
    );

    Widget button;

    switch (type) {
      case ButtonType.primary:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: MethodistTheme.primaryButtonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.secondary:
        button = OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: MethodistTheme.secondaryButtonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: loading ? null : onPressed,
          style: MethodistTheme.textButtonStyle,
          child: buttonChild,
        );
        break;
      case ButtonType.danger:
        button = ElevatedButton(
          onPressed: loading ? null : onPressed,
          style: MethodistTheme.dangerButtonStyle,
          child: buttonChild,
        );
        break;
    }

    return SizedBox(
      width: fullWidth ? double.infinity : width,
      height: height ?? 48,
      child: button,
    );
  }
}