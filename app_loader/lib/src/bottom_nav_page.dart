import 'package:app_loader/src/app_descriptor.dart';
import 'package:app_loader/src/app_theme.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'incoming_progress.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.incomingMediaViewBuilder,
    super.key,
  });

  final StatefulNavigationShell child;
  final IncomingMediaViewBuilder incomingMediaViewBuilder;
  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return IncomingMediaHandler(
      incomingMediaViewBuilder: widget.incomingMediaViewBuilder,
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
