import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';

class AppButtons {
  static ButtonStyle primary(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: context.colors.primary,
      foregroundColor: context.colors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: context.radiusMd),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingLg,
        vertical: context.spacingMd,
      ),
    );
  }

  static ButtonStyle secondary(BuildContext context) {
    return OutlinedButton.styleFrom(
      backgroundColor: Colors.transparent,
      foregroundColor: context.colors.primary,
      side: BorderSide(color: context.colors.primary),
      shape: RoundedRectangleBorder(borderRadius: context.radiusMd),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingLg,
        vertical: context.spacingMd,
      ),
    );
  }

  static ButtonStyle text(BuildContext context) {
    return TextButton.styleFrom(
      foregroundColor: context.colors.primary,
      shape: RoundedRectangleBorder(borderRadius: context.radiusMd),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingLg,
        vertical: context.spacingMd,
      ),
    );
  }

  static ButtonStyle danger(BuildContext context) {
    return ElevatedButton.styleFrom(
      backgroundColor: context.colors.error,
      foregroundColor: context.colors.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: context.radiusMd),
      padding: EdgeInsets.symmetric(
        horizontal: context.spacingLg,
        vertical: context.spacingMd,
      ),
    );
  }
}
