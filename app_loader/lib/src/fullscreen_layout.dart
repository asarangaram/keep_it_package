import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class FullscreenLayout extends StatelessWidget {
  const FullscreenLayout({required this.child, super.key, this.onClose});
  final Widget child;
  final void Function()? onClose;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppTheme(
      child: CLFullscreenBox(
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
                      color: Theme.of(context)
                          .colorScheme
                          .background
                          .withAlpha(192),
                      onTap: onClose,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
