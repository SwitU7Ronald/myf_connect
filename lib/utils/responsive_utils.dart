import 'package:flutter/material.dart';

class ResponsiveUtils {
  final BuildContext context;

  ResponsiveUtils(this.context);

  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;

  bool get isSmallPhone => screenWidth < 360;
  bool get isPhone => screenWidth < 600;
  bool get isTablet => screenWidth >= 600 && screenWidth < 900;
  bool get isDesktop => screenWidth >= 900;

  bool get isPortrait =>
      MediaQuery.orientationOf(context) == Orientation.portrait;
  bool get isLandscape =>
      MediaQuery.orientationOf(context) == Orientation.landscape;

  double wp(double percentage) => screenWidth * percentage / 100;
  double hp(double percentage) => screenHeight * percentage / 100;

  double get textScaleFactor => MediaQuery.textScaleFactorOf(context);

  double responsiveFontSize(double baseFontSize) {
    double scaleFactor = screenWidth / 375;
    return baseFontSize * scaleFactor.clamp(0.8, 1.3);
  }

  EdgeInsets responsivePadding({
    double? all,
    double? horizontal,
    double? vertical,
    double? left,
    double? right,
    double? top,
    double? bottom,
  }) {
    final scale = screenWidth / 375;
    return EdgeInsets.only(
      left: (left ?? horizontal ?? all ?? 0) * scale,
      right: (right ?? horizontal ?? all ?? 0) * scale,
      top: (top ?? vertical ?? all ?? 0) * scale,
      bottom: (bottom ?? vertical ?? all ?? 0) * scale,
    );
  }

  double spacing(double baseSpacing) {
    return baseSpacing * (screenWidth / 375).clamp(0.8, 1.2);
  }

  double borderRadius(double baseRadius) {
    return baseRadius * (screenWidth / 375).clamp(0.8, 1.2);
  }

  EdgeInsets get safeAreaPadding => MediaQuery.paddingOf(context);
  double get topSafeArea => safeAreaPadding.top;
  double get bottomSafeArea => safeAreaPadding.bottom;

  double iconSize(double baseSize) {
    return baseSize * (screenWidth / 375).clamp(0.9, 1.3);
  }

  int get gridColumns {
    if (isSmallPhone) return 1;
    if (isPhone) return 2;
    if (isTablet) return 3;
    return 4;
  }

  double get listItemHeight {
    if (isSmallPhone) return 140;
    if (isPhone) return 160;
    return 180;
  }

  double get buttonHeight {
    if (isSmallPhone) return 44;
    if (isPhone) return 48;
    return 52;
  }

  double get cardElevation => isSmallPhone ? 1 : 2;
}

extension ResponsiveExtension on BuildContext {
  ResponsiveUtils get responsive => ResponsiveUtils(this);

  double wp(double percentage) => ResponsiveUtils(this).wp(percentage);
  double hp(double percentage) => ResponsiveUtils(this).hp(percentage);
  double responsiveFont(double size) =>
      ResponsiveUtils(this).responsiveFontSize(size);
  double spacing(double value) => ResponsiveUtils(this).spacing(value);
}

class ResponsiveText extends StatelessWidget {
  final String text;
  final double baseFontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const ResponsiveText(
    this.text, {
    super.key,
    required this.baseFontSize,
    this.fontWeight,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: context.responsiveFont(baseFontSize),
        fontWeight: fontWeight,
        color: color,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

class ResponsivePadding extends StatelessWidget {
  final Widget child;
  final double? all;
  final double? horizontal;
  final double? vertical;
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  const ResponsivePadding({
    super.key,
    required this.child,
    this.all,
    this.horizontal,
    this.vertical,
    this.left,
    this.right,
    this.top,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: context.responsive.responsivePadding(
        all: all,
        horizontal: horizontal,
        vertical: vertical,
        left: left,
        right: right,
        top: top,
        bottom: bottom,
      ),
      child: child,
    );
  }
}

class ResponsiveSizedBox extends StatelessWidget {
  final double? width;
  final double? height;
  final Widget? child;

  const ResponsiveSizedBox({super.key, this.width, this.height, this.child});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width != null ? context.spacing(width!) : null,
      height: height != null ? context.spacing(height!) : null,
      child: child,
    );
  }
}
