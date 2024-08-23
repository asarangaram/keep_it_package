import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

class FullscreenLayout extends StatelessWidget {
  const FullscreenLayout({
    required this.child,
    super.key,
    // this.onClose,
    this.useSafeArea = true,
    this.backgroundColor,
    this.hasBorder = false,
    this.backgroundBrightness = 0.25,
    this.hasBackground = true,
    this.bottomNavigationBar,
  });
  final Widget child;
  // final void Function()? onClose;
  final bool useSafeArea;
  final Color? backgroundColor;
  final bool hasBorder;
  final double backgroundBrightness;
  final bool hasBackground;
  final Widget? bottomNavigationBar;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (foundInContext(context)) {
      // don't create it again
      throw Exception('FullscreenLayout is used multiple times');
      //return child;
    }
    return _ValidateLayout(
      validLayout: true,
      child: CLFullscreenBox(
        hasBackground: hasBackground,
        backgroundColor: backgroundColor,
        hasBorder: hasBorder,
        backgroundBrightness: backgroundBrightness,
        bottomNavigationBar: bottomNavigationBar,
        useSafeArea: useSafeArea,
        child: NotificationService(
          child: _ValidateLayout(
            validLayout: true,
            child: child,
          ),
        ),
      ),
    );
  }

  static bool foundInContext(BuildContext context) =>
      _ValidateLayout.isValidLayout(context);
}

class _ValidateLayout extends InheritedWidget {
  const _ValidateLayout({
    required super.child,
    required this.validLayout,
  });
  final bool validLayout;

  @override
  bool updateShouldNotify(_ValidateLayout oldWidget) {
    return false;
  }

  static bool isValidLayout(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<_ValidateLayout>()
            ?.validLayout ??
        false;
  }
}
