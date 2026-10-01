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
