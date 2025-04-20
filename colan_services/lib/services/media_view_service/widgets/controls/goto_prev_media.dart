import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../../providers/show_controls.dart';
import '../../providers/media_view_state.dart';

class OnGotoPrevMedia extends ConsumerWidget {
  const OnGotoPrevMedia({required this.pageController, super.key});
  final PageController pageController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaViewerState = ref.watch(mediaViewerStateProvider);
    final isFullScreen =
        ref.watch(showControlsProvider.select((e) => e.isFullScreen));
    if (isFullScreen) {
      return const SizedBox.shrink();
    }
    return ShadButton.ghost(
      padding: EdgeInsets.zero,
      onPressed: () {
        if (mediaViewerState.currentIndex > 0) {
          pageController.previousPage(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        } else {
          pageController.animateToPage(
            mediaViewerState.entities.length - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      },
      child: const CLIcon.large(LucideIcons.chevronLeft),
    );
  }
}
