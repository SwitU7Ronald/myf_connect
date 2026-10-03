import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/widgets/widgets.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: context.colors.primary),
          if (message != null) ...[
            SizedBox(height: context.spacingMd),
            Text(
              message!,
              style: context.typography.bodyMedium!.copyWith(
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.spacingLg),
              decoration: BoxDecoration(
                color: context.colors.textSecondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(32),
                ),
              ),
              child: Icon(
                icon,
                size: context.responsiveIconSize(64),
                color: context.colors.textSecondary,
              ),
            ),
            SizedBox(height: context.spacingLg),
            Text(
              title,
              style: context.typography.bodyMedium!.copyWith(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.spacingMd),
            Text(
              description,
              style: context.typography.bodyMedium!.copyWith(
                fontSize: context.responsiveFontSize(14),
                color: context.colors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class ErrorStateWidget extends StatelessWidget {
  final String title;
  final String? description;
  final String? retryLabel;
  final VoidCallback? onRetry;

  const ErrorStateWidget({
    super.key,
    required this.title,
    this.description,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(context.spacingXl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(context.spacingLg),
              decoration: BoxDecoration(
                color: context.colors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(32),
                ),
              ),
              child: Icon(
                Icons.error_outline,
                size: context.responsiveIconSize(64),
                color: context.colors.error,
              ),
            ),
            SizedBox(height: context.spacingLg),
            Text(
              title,
              style: context.typography.bodyMedium!.copyWith(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w600,
                color: context.colors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              SizedBox(height: context.spacingMd),
              Text(
                description!,
                style: context.typography.bodyMedium!.copyWith(
                  fontSize: context.responsiveFontSize(14),
                  color: context.colors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (onRetry != null && retryLabel != null) ...[
              SizedBox(height: context.spacingLg),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  retryLabel!,
                  style: context.typography.bodyMedium!,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.colors.primary,
                  foregroundColor: context.colors.surface,
                  padding: context.responsivePadding(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.radiusMd.topLeft.x,
                    ),
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

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final String loadingMessage;
  final Widget child;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.loadingMessage,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Positioned.fill(
            child: Container(
              color: context.colors.textPrimary.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  padding: EdgeInsets.all(context.spacingXl),
                  margin: EdgeInsets.all(context.spacingLg),
                  decoration: BoxDecoration(
                    color: context.colors.surface,
                    borderRadius: BorderRadius.circular(
                      context.radiusLg.topLeft.x,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colors.textPrimary.withValues(alpha: 0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: LoadingWidget(message: loadingMessage),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
