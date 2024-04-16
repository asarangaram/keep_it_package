import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class FullscreenLayout extends StatelessWidget {
  const FullscreenLayout({
    required this.child,
    super.key,
    this.onClose,
    this.useSafeArea = true,
    this.backgroundColor,
    this.hasBorder = false,
    this.backgroundBrightness = 0.25,
    this.hasBackground = true,
    this.bottomNavigationBar,
  });
  final Widget child;
  final void Function()? onClose;
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
    /* return CLFullscreenBox(
      useSafeArea: true,
      child: NotificationService(
        child: Stack(
          children: [
            child,
            if (onClose != null)
              Positioned(
                top: 4,
                right: 12,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context)
                        .colorScheme
                        .onBackground
                        .withAlpha(192), // Color for the circular container
                  ),
                  child: CLButtonIcon.small(
                    Icons.close,
                    color:
                        Theme.of(context).colorScheme.background.withAlpha(192),
                    onTap: onClose,
                  ),
                ),
              ),
          ],
        ),
      ),
    ); */
    return CLFullscreenBox(
      hasBackground: hasBackground,
      backgroundColor: backgroundColor,
      hasBorder: hasBorder,
      backgroundBrightness: backgroundBrightness,
      bottomNavigationBar: bottomNavigationBar,
      useSafeArea: useSafeArea,
      child: NotificationService(
        child: Column(
          children: [
            if (onClose != null)
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context)
                          .colorScheme
                          .onBackground
                          .withAlpha(192), // Color for the circular container
                    ),
                    child: CLButtonIcon.small(
                      Icons.close,
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(192),
                      onTap: onClose,
                    ),
                  ),
                ),
              ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
