import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/change_monitor.dart';

class ChangeMonitor extends ConsumerWidget {
  const ChangeMonitor({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localChangeMonitorAsync = ref.watch(localChangeMonitorProvider);
    final whenNoChange = CLIcon.tiny(
      Icons.upload,
      color: Theme.of(context).disabledColor,
    );
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));
    return localChangeMonitorAsync.whenOrNull(
          data: (data) {
            if (data.hasChange) {
              return CLBlink(
                blinkDuration: const Duration(milliseconds: 300),
                child: CLButtonIcon.tiny(
                  Icons.upload,
                  color: canSync ? null : Colors.red,
                  onTap: canSync ? () {} : null,
                ),
              );
            }
            return whenNoChange;
          },
        ) ??
        whenNoChange;
  }
}
