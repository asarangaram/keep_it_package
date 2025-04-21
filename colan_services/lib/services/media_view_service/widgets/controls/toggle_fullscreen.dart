import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../providers/show_controls.dart';
import 'cl_icons.dart';

class OnToggleFullScreen extends ConsumerWidget {
  const OnToggleFullScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return CLButtonIcon.small(
      showControl.isFullScreen
          ? videoPlayerIcons.fullscreenExit
          : videoPlayerIcons.fullscreen,
      onTap: ref.read(showControlsProvider.notifier).fullScreenToggle,
      color: ShadTheme.of(context).colorScheme.background,
    );
  }
}
