import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/cl_route_descriptor.dart';
import 'app_theme.dart';

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
              child: CLPopScreen.onSwipe(
                child: ChildWithDownloadProgress(
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ChildWithDownloadProgress extends ConsumerWidget {
  const ChildWithDownloadProgress({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runningTasks = ref.watch(runningTasksProvider).whenOrNull(
          data: (runningTasks) => runningTasks.isEmpty ? null : runningTasks,
        );

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(child: child),
        if (runningTasks != null) ...[
          Text('Running ${runningTasks.length}'),
          const LinearProgressIndicator(backgroundColor: Colors.red),
        ],
      ],
    );
  }
}
