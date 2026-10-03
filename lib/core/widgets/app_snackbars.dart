import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';

class AppSnackbars {
  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.typography.bodyMedium!.copyWith(color: context.colors.surface)),
        backgroundColor: context.colors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: context.radiusMd,
        ),
      ),
    );
  }

  static void showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.typography.bodyMedium!.copyWith(color: context.colors.surface)),
        backgroundColor: context.colors.error,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(
          borderRadius: context.radiusMd,
        ),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.typography.bodyMedium!.copyWith(color: context.colors.surface)),
        backgroundColor: context.colors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: context.radiusMd,
        ),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: context.typography.bodyMedium!.copyWith(color: context.colors.surface)),
        backgroundColor: context.colors.info,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: context.radiusMd,
        ),
      ),
    );
  }
}
