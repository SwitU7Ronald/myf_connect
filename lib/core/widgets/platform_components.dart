import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:myf_connect/core/theme/theme.dart';
import 'package:myf_connect/core/theme/theme_extensions.dart';


bool get isApplePlatform =>
    defaultTargetPlatform == TargetPlatform.iOS ||
    defaultTargetPlatform == TargetPlatform.macOS;

class PlatformAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;

  const PlatformAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    if (isApplePlatform) {
      final effectiveBgColor =
          backgroundColor ??
          Theme.of(context).appBarTheme.backgroundColor ??
          Theme.of(context).primaryColor;
      final effectiveFgColor =
          foregroundColor ?? Theme.of(context).appBarTheme.foregroundColor;

      Widget bar = ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            color: effectiveBgColor.withValues(alpha: 0.5),
            child: SafeArea(
              bottom: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: kToolbarHeight,
                    child: NavigationToolbar(
                      leading:
                          leading ??
                          (Navigator.canPop(context)
                              ? BackButton(color: effectiveFgColor)
                              : null),
                      middle: title != null
                          ? DefaultTextStyle.merge(
                              style:
                                  Theme.of(context).appBarTheme.titleTextStyle
                                      ?.copyWith(color: effectiveFgColor) ??
                                  context.typography.titleLarge!.copyWith(
                                    color: effectiveFgColor,
                                  ),
                              child: title!,
                            )
                          : null,
                      trailing: actions != null
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: actions!,
                            )
                          : null,
                      centerMiddle: centerTitle,
                    ),
                  ),
                  ?bottom,
                ],
              ),
            ),
          ),
        ),
      );

      if (elevation != null && elevation! > 0) {
        return Material(
          elevation: elevation!,
          color: Colors.transparent,
          child: bar,
        );
      }
      return bar;
    }

    return AppBar(
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}

class PlatformScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool extendBodyBehindAppBar;
  final bool extendBody;
  final Color? backgroundColor;

  const PlatformScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.extendBodyBehindAppBar = false,
    this.extendBody = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      extendBodyBehindAppBar: isApplePlatform ? true : extendBodyBehindAppBar,
      extendBody: isApplePlatform && bottomNavigationBar != null
          ? true
          : extendBody,
      appBar: appBar,
      body: isApplePlatform
          ? SafeArea(
              top: false, // Let content scroll under the blurred app bar
              bottom: bottomNavigationBar == null,
              child: body,
            )
          : body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: isApplePlatform && bottomNavigationBar != null
          ? ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: ColoredBox(
                  color: Theme.of(
                    context,
                  ).scaffoldBackgroundColor.withValues(alpha: 0.5),
                  child: bottomNavigationBar,
                ),
              ),
            )
          : bottomNavigationBar,
    );
  }
}

class PlatformAlertDialog extends StatelessWidget {
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final EdgeInsetsGeometry? contentPadding;
  final EdgeInsetsGeometry? actionsPadding;

  const PlatformAlertDialog({
    super.key,
    this.title,
    this.content,
    this.actions,
    this.contentPadding,
    this.actionsPadding,
  });

  @override
  Widget build(BuildContext context) {
    if (isApplePlatform) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(context.radiusL),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: Theme.of(context).cardColor.withValues(alpha: 0.5),
              padding: contentPadding ?? EdgeInsets.all(context.spacingLg),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    DefaultTextStyle.merge(
                      style:
                          Theme.of(context).textTheme.titleLarge ??
                          context.typography.titleLarge!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      textAlign: TextAlign.center,
                      child: title!,
                    ),
                    SizedBox(height: context.spacingMd),
                  ],
                  if (content != null) Flexible(child: content!),
                  if (actions != null) ...[
                    if (actionsPadding != null)
                      Padding(
                        padding: actionsPadding!,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: actions!,
                        ),
                      )
                    else ...[
                      SizedBox(height: context.spacingLg),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: actions!,
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }

    return AlertDialog(
      title: title,
      content: content,
      actions: actions,
      contentPadding:
          contentPadding ??
          context.responsivePadding(
            left: 24.0,
            top: 20.0,
            right: 24.0,
            bottom: 24.0,
          ),
      actionsPadding: actionsPadding ?? EdgeInsets.zero,
    );
  }
}

extension PlatformContextExtension on BuildContext {
  /// Returns the height of the app bar overlap on Apple platforms.
  /// Use this to pad the top of Lists or Columns to prevent them from being hidden under the blurred PlatformAppBar.
  double get appBarOverlap {
    if (isApplePlatform) {
      return MediaQuery.of(this).padding.top + kToolbarHeight;
    }
    return 0.0;
  }
}
