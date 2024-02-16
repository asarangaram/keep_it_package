import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/widgets.dart';

import 'app_theme.dart';

class FullscreenLayout extends StatelessWidget {
  const FullscreenLayout({required this.child, super.key});
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    return AppTheme(
      child: CLFullscreenBox(
        useSafeArea: true,
        child: NotificationService(child: child),
      ),
    );
  }
}
