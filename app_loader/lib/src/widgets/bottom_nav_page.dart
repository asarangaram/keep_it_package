import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/cl_route_descriptor.dart';
import 'app_theme.dart';
import 'incoming_media_monitor.dart';
import 'validate_layout.dart';

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
    required CLMediaFileGroup incomingMedia,
    required void Function({required bool result}) onDiscard,
  }) onMedia;

  @override
  ConsumerState<BottomNavigationPage> createState() =>
      _BottomNavigationPageState();
}

class _BottomNavigationPageState extends ConsumerState<BottomNavigationPage> {
  @override
  Widget build(BuildContext context) {
    //const connectionStatusColor = Color.fromARGB(255, 231, 249, 234);
    const connectionStatusColor = Color.fromARGB(255, 231, 249, 234);
    return AppTheme(
      child: IncomingMediaMonitor(
        onMedia: widget.onMedia,
        child: ValidateLayout(
          validLayout: true,
          child: CLFullscreenBox(
            useSafeArea: true,
            bottomNavigationBar: BottomNavigationBar(
              backgroundColor: connectionStatusColor.reduceBrightness(0.2),
              selectedFontSize: 0,
              unselectedFontSize: 0,
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
                    icon: e.iconData,
                    label: e.label,
                  );
                }),
              ],
            ),
            child: NotificationService(
              child: CLPopScreen.onSwipe(
                child: widget.child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
