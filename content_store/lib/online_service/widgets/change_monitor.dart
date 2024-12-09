import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/change_monitor.dart';

class ChangeMonitor extends ConsumerWidget {
  const ChangeMonitor({super.key});
  static Widget? whenNoLocalChange;
  static Widget? whenNoServerChange;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localChangeMonitorAsync = ref.watch(localChangeMonitorProvider);
    final serverChangeMonitorAsync = ref.watch(serverChangeMonitorProvider);
    whenNoLocalChange ??= CLIcon.tiny(
      Icons.upload,
      color: Theme.of(context).disabledColor,
    );
    whenNoServerChange ??= CLIcon.tiny(
      Icons.download,
      color: Theme.of(context).disabledColor,
    );
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        serverChangeMonitorAsync.whenOrNull(
              data: (data) {
                if (data.hasChange) {
                  if (canSync) {
                    return CLBlink(
                      blinkDuration: const Duration(milliseconds: 300),
                      child: CLButtonIcon.tiny(
                        Icons.download,
                        onTap: () {},
                      ),
                    );
                  } else {
                    return const CLButtonIcon.tiny(
                      Icons.download,
                      color: Colors.red,
                    );
                  }
                }
                return null;
              },
            ) ??
            whenNoServerChange!,
        localChangeMonitorAsync.whenOrNull(
              data: (data) {
                if (data.hasChange) {
                  if (canSync) {
                    return CLBlink(
                      blinkDuration: const Duration(milliseconds: 300),
                      child: CLButtonIcon.tiny(
                        Icons.upload,
                        onTap: () {},
                      ),
                    );
                  } else {
                    return const CLButtonIcon.tiny(
                      Icons.upload,
                      color: Colors.red,
                    );
                  }
                }
                return null;
              },
            ) ??
            whenNoLocalChange!,
      ],
    );
  }
}
