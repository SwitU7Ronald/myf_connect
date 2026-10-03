import 'package:flutter/material.dart';

/// A wrapper widget that constrains its child's width on large screens
/// and centers it. This prevents UI elements from stretching endlessly
/// on tablets, desktops, and web.
class ResponsiveConstrainedBox extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final AlignmentGeometry alignment;
  final bool clampHeight;

  const ResponsiveConstrainedBox({
    super.key,
    required this.child,
    this.maxWidth = 800.0,
    this.alignment = Alignment.topCenter,
    this.clampHeight = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: clampHeight ? IntrinsicHeight(child: child) : child,
      ),
    );
  }
}

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    required this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600.0; // ResponsiveBreakpoints.mobile

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600.0 &&
      MediaQuery.of(context).size.width < 840.0; // ResponsiveBreakpoints.tablet

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >=
      840.0; // ResponsiveBreakpoints.tablet

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840.0) {
          return desktop;
        } else if (constraints.maxWidth >= 600.0) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}
