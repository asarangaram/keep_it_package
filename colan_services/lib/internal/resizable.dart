import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

class ResizablePage extends ConsumerStatefulWidget {
  const ResizablePage({required this.top, super.key, this.bottom});
  final Widget top;
  final Widget? bottom;

  @override
  ConsumerState<ResizablePage> createState() => _ResizablePageState();
}

class _ResizablePageState extends ConsumerState<ResizablePage> {
  late final ShadResizableController controller;
  late final double topSize;
  @override
  void initState() {
    topSize = ref.read(lastKnownPanelSize);
    controller = ShadResizableController()..addListener(_listener);
    super.initState();
  }

  @override
  void dispose() {
    controller
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }

  void _listener() {
    ref.read(lastKnownPanelSize.notifier).state =
        controller.getPanelInfo(0).size;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    return ClipRRect(
      borderRadius: theme.radius,
      child: ShadResizablePanelGroup(
        axis: Axis.vertical,
        dividerColor: theme.colorScheme.muted,
        controller: controller,
        children: [
          ShadResizablePanel(
            minSize: 0.4,
            maxSize: 0.8,
            defaultSize: topSize,
            child: widget.top,
          ),
          ShadResizablePanel(
            defaultSize: 1 - topSize,
            child: widget.bottom ??
                Center(
                  child: Text('Empty', style: theme.textTheme.large),
                ),
          ),
        ],
      ),
    );
  }
}

final lastKnownPanelSize = StateProvider<double>((ref) {
  return 0.4;
});
