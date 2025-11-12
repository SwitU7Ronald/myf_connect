import 'package:flutter/material.dart';
import '../app/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,  // ✅ ADDED - Prevents overflow
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: MethodistTheme.primaryRed,
          ),
          if (message != null) ...[
            SizedBox(height: context.spacing(16)),
            Text(
              message!,
              style: context.responsiveBodyMedium.copyWith(
                color: MethodistTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

// ========================================
// EMPTY STATE WIDGET - Already good, minor optimization
// ========================================
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
      child: SingleChildScrollView(  // ✅ ADDED: Allows scrolling if content is tall
        padding: context.responsivePadding(all: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ✅ ADDED: Prevents overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.responsivePadding(all: 24),
              decoration: BoxDecoration(
                color: MethodistTheme.mediumGray.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(32),
                ),
              ),
              child: Icon(
                icon,
                size: context.responsiveIconSize(64),
                color: MethodistTheme.mediumGray,
              ),
            ),
            SizedBox(height: context.spacing(24)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w600,
                color: MethodistTheme.darkGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,  // ✅ ADDED: Limit title lines
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: context.spacing(12)),
            Text(
              description,
              style: TextStyle(
                fontSize: context.responsiveFontSize(14),
                color: MethodistTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,  // ✅ ADDED: Handle overflow
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// ERROR STATE WIDGET - Fixed for keyboard safety
// ========================================
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
      child: SingleChildScrollView(  // ✅ ADDED: Keyboard-safe
        padding: context.responsivePadding(all: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,  // ✅ ADDED: Prevents overflow
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: context.responsivePadding(all: 24),
              decoration: BoxDecoration(
                color: MethodistTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(
                  context.responsiveRadius(32),
                ),
              ),
              child: Icon(
                Icons.error_outline,  // ✅ CHANGED: Better icon for errors
                size: context.responsiveIconSize(64),
                color: MethodistTheme.errorRed,
              ),
            ),
            SizedBox(height: context.spacing(24)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.responsiveFontSize(18),
                fontWeight: FontWeight.w600,
                color: MethodistTheme.darkGray,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,  // ✅ ADDED: Limit title lines
              overflow: TextOverflow.ellipsis,
            ),
            if (description != null) ...[
              SizedBox(height: context.spacing(12)),
              Text(
                description!,
                style: TextStyle(
                  fontSize: context.responsiveFontSize(14),
                  color: MethodistTheme.mediumGray,
                ),
                textAlign: TextAlign.center,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,  // ✅ ADDED: Handle overflow
              ),
            ],
            if (onRetry != null && retryLabel != null) ...[
              SizedBox(height: context.spacing(24)),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(
                  retryLabel!,
                  style: TextStyle(
                    fontSize: context.responsiveFontSize(14),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: MethodistTheme.primaryRed,  // ✅ ADDED: Consistent theming
                  foregroundColor: MethodistTheme.white,
                  padding: context.responsivePadding(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      context.responsiveRadius(12),
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

// ========================================
// LOADING OVERLAY - Fixed for keyboard safety
// ========================================
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
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Container(
                  // ✅ ADDED: Card background for better visibility
                  padding: context.responsivePadding(all: 32),
                  margin: context.responsivePadding(all: 24),
                  decoration: BoxDecoration(
                    color: MethodistTheme.white,
                    borderRadius: BorderRadius.circular(
                      context.responsiveRadius(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
