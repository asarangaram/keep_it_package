import 'package:app_loader/src/app_descriptor.dart';
import 'package:app_loader/src/app_theme.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'incoming_progress.dart';
import 'providers/incoming_media.dart';

class StandalonePage extends ConsumerWidget {
  const StandalonePage({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppTheme(
      child: CLFullscreenBox(child: NotificationService(child: child)),
    );
  }
}

class BottomNavigationPage extends ConsumerStatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.incomingMediaViewBuilder,
    super.key,
  });

  final StatefulNavigationShell child;
  final IncomingMediaViewBuilder incomingMediaViewBuilder;
  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    final incomingMedia = ref.watch(incomingMediaStreamProvider);

    if (incomingMedia.isNotEmpty) {
      return StandalonePage(
        child: IncomingProgress(
          key: ValueKey(incomingMedia[0]),
          incomingMedia: incomingMedia[0],
          incomingMediaViewBuilder: widget.incomingMediaViewBuilder,
          onDone: () {
            ref.read(incomingMediaStreamProvider.notifier).pop();
          },
        ),
      );
    }

    return AppTheme(
      child: CLFullscreenBox(
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: widget.child.currentIndex,
          onTap: (index) {
            widget.child.goBranch(
              index,
              initialLocation: index == widget.child.currentIndex,
            );
            setState(() {});
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_special_rounded),
              label: 'Collections',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.search),
              label: 'search',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'settings',
            ),
          ],
        ),
        child: NotificationService(
          child: GestureDetector(
            onHorizontalDragEnd: (details) {
              if (details.primaryVelocity == null) return;
              // pop on Swipe
              if (details.primaryVelocity! > 0) {
                if (context.canPop()) {
                  context.pop();
                } else {
                  if (widget.child.currentIndex == 1) {
                    widget.child.goBranch(
                      0,
                    );
                  }
                  if (widget.child.currentIndex == 2) {
                    widget.child.goBranch(
                      1,
                    );
                  }
                }
              }

              // Swiping in left direction.
              if (details.primaryVelocity! < 0) {
                if (widget.child.currentIndex == 0) {
                  widget.child.goBranch(
                    1,
                  );
                }
                if (widget.child.currentIndex == 1) {
                  widget.child.goBranch(
                    2,
                  );
                }
              }
            },
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
