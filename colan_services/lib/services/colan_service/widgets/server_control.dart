import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../../store_service/providers/store.dart';
import '../providers/downloader_status.dart';
import '../providers/online_status.dart';
import '../providers/working_offline.dart';
import 'controls.dart';
import 'downloader_progressbar.dart';

class ServerControl extends ConsumerWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(serverOnlineStatusProvider);
    final workingOffline = ref.watch(workingOfflineProvider);

    // ignore: unused_local_variable
    final downloaderStatus = ref.watch(downloaderStatusProvider);
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      elevation: 16,
      color: Theme.of(context).colorScheme.primaryContainer,
      // padding: const EdgeInsets.all(2),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          children: [
            SpeedDial(
              overlayOpacity: 0,
              elevation: 0,
              buttonSize: const Size(30, 30),
              children: [
                if (isOnline)
                  if (!workingOffline)
                    SpeedDialChild(
                      onTap: () {
                        ref.read(workingOfflineProvider.notifier).state = true;
                      },
                      labelWidget: const SpeedDialChildWrapper(
                        child: WorkOffline(),
                      ),
                    )
                  else
                    SpeedDialChild(
                      onTap: () {
                        ref.read(workingOfflineProvider.notifier).state = false;
                      },
                      labelWidget: const SpeedDialChildWrapper(
                        child: GoOnline(),
                      ),
                    ),
                if (isOnline && !workingOffline)
                  SpeedDialChild(
                    onTap: ref.read(storeProvider.notifier).syncServer,
                    labelWidget: const SyncServer(),
                  ),
              ],
              switchLabelPosition: true,
              activeIcon: clIcons.closeFullscreen,
              child: Image.asset(
                'assets/icon/cloud_on_lan_128px_color.png',
              ),
            ),
            if (downloaderStatus.total > 0)
              const SizedBox.square(
                dimension: 30,
                child: DownloaderProgressPie(),
              ),
            if (downloaderStatus.running > 0)
              const SizedBox.square(
                dimension: 30,
                child: ActiveDownloadIndicator(),
              ),
            //const Spacer(),
          ]
              .map(
                (e) => Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: e,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}

class SpeedDialChildWrapper extends StatelessWidget {
  const SpeedDialChildWrapper({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
    /* return Container(
      padding: const EdgeInsets.only(left: 32),
      alignment: Alignment.centerLeft,
      width: 200,
      height: 40,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: child,
      ),
    ); */
  }
}
