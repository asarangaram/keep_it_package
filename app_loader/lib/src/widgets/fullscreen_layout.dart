import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';

import 'validate_layout.dart';

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
    return CLFullscreenBox(
      hasBackground: hasBackground,
      backgroundColor: backgroundColor,
      hasBorder: hasBorder,
      backgroundBrightness: backgroundBrightness,
      bottomNavigationBar: bottomNavigationBar,
      useSafeArea: useSafeArea,
      child: NotificationService(
        child: ValidateLayout(
          validLayout: true,
          child: child,
        ),
      ),
    );
  }

  static bool foundInContext(BuildContext context) =>
      ValidateLayout.isValidLayout(context);
}
