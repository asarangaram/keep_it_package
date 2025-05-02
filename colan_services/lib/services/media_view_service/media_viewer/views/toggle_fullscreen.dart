import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../notifier/ui_state.dart';
import 'video_progress.dart' show MenuBackground;

class OnToggleFullScreen extends ConsumerWidget {
  const OnToggleFullScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MenuBackground(
      child: ListenableBuilder(
        listenable: uiStateManager.notifier,
        builder: (_, __) {
          final isFullScreen = !uiStateManager.notifier.state.showMenu;

          return CLButtonIcon.standard(
            isFullScreen ? LucideIcons.minimize2 : LucideIcons.maximize2,
            onTap: uiStateManager.notifier.toggleMenu,
            color: ShadTheme.of(context).colorScheme.background,
          );
        },
      ),
    );
  }
}
