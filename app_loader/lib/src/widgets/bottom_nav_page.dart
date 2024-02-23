import 'package:app_loader/src/widgets/app_theme.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'incoming_media_monitor.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.onMedia,
    super.key,
  });

  final StatefulNavigationShell child;
  final Widget Function(
    BuildContext context, {
    required CLMediaList incomingMedia,
    required void Function() onDiscard,
  }) onMedia;

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return IncomingMediaMonitor(
      onMedia: widget.onMedia,
      child: AppTheme(
        child: CLFullscreenBox(
          useSafeArea: true,
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
      ),
    );
  }
}
