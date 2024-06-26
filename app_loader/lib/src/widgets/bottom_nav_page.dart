import 'package:app_loader/src/widgets/app_theme.dart';
import 'package:app_loader/src/widgets/validate_layout.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app_loader.dart';

class BottomNavigationPage extends ConsumerStatefulWidget {
  const BottomNavigationPage({
    required this.child,
    required this.routes,
    required this.onMedia,
    super.key,
  });

  final StatefulNavigationShell child;
  final List<CLShellRouteDescriptor> routes;
  final Widget Function(
    BuildContext context, {
    required CLSharedMedia incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return AppTheme(
      child: IncomingMediaMonitor(
        onMedia: widget.onMedia,
        child: ValidateLayout(
          validLayout: true,
          child: CLFullscreenBox(
            useSafeArea: true,
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: widget.child.currentIndex,
              onTap: (index) {
                CLQuickMenuAnchor.clearQuickMenu(context, ref);

                widget.child.goBranch(
                  index,
                  initialLocation: index == widget.child.currentIndex,
                );
                setState(() {});
              },
              items: [
                ...widget.routes.map((e) {
                  return BottomNavigationBarItem(
                    icon: Icon(e.iconData),
                    label: e.label,
                  );
                }),
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
                      /*  if (widget.child.currentIndex == 1) {
                        widget.child.goBranch(
                          0,
                        );
                      }
                      if (widget.child.currentIndex == 2) {
                        widget.child.goBranch(
                          1,
                        );
                      } */
                    }
                  }

                  // Swiping in left direction.
                  if (details.primaryVelocity! < 0) {
                    /*  if (widget.child.currentIndex == 0) {
                      widget.child.goBranch(
                        1,
                      );
                    }
                    if (widget.child.currentIndex == 1) {
                      widget.child.goBranch(
                        2,
                      );
                    } */
                  }
                },
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
