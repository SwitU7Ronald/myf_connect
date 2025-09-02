import 'package:flutter/material.dart';
import '../app/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? MethodistTheme.primaryRed,
            ),
          ),
          if (message != null) ...[
            SizedBox(height: MethodistTheme.spacingM),
            Text(
              message!,
              style: MethodistTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final Widget child;
  final bool isLoading;
  final String? loadingMessage;

  const LoadingOverlay({
    super.key,
    required this.child,
    required this.isLoading,
    this.loadingMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: LoadingWidget(message: loadingMessage),
          ),
      ],
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onActionPressed;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    this.description,
    this.actionLabel,
    this.onActionPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MethodistTheme.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: MethodistTheme.paddingL,
              decoration: BoxDecoration(
                color: MethodistTheme.lightGray,
                borderRadius: BorderRadius.circular(MethodistTheme.radiusXXL),
              ),
              child: Icon(
                icon,
                size: 48,
                color: MethodistTheme.mediumGray,
              ),
            ),
            SizedBox(height: MethodistTheme.spacingL),
            Text(
              title,
              style: MethodistTheme.headlineSmall.copyWith(
                color: MethodistTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: MethodistTheme.spacingM),
              Text(
                description!,
                style: MethodistTheme.bodyMedium.copyWith(
                  color: MethodistTheme.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onActionPressed != null) ...[
              SizedBox(height: MethodistTheme.spacingXL),
              ElevatedButton(
                onPressed: onActionPressed,
                child: Text(actionLabel!),
              ),
            ],
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
    this.title = 'Something went wrong',
    this.description,
    this.retryLabel = 'Retry',
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: MethodistTheme.paddingXL,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: MethodistTheme.paddingL,
              decoration: BoxDecoration(
                color: MethodistTheme.errorRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(MethodistTheme.radiusXXL),
              ),
              child: Icon(
                Icons.error,
                size: 48,
                color: MethodistTheme.errorRed,
              ),
            ),
            SizedBox(height: MethodistTheme.spacingL),
            Text(
              title,
              style: MethodistTheme.headlineSmall.copyWith(
                color: MethodistTheme.darkGray,
              ),
              textAlign: TextAlign.center,
            ),
            if (description != null) ...[
              SizedBox(height: MethodistTheme.spacingM),
              Text(
                description!,
                style: MethodistTheme.bodyMedium.copyWith(
                  color: MethodistTheme.mediumGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (onRetry != null && retryLabel != null) ...[
              SizedBox(height: MethodistTheme.spacingXL),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}