import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../builders/get_downloader.dart';
import '../builders/get_server.dart';
import '../providers/server.dart';
import 'change_monitor.dart';
import 'controls.dart';
import 'downloader_progressbar.dart';

class ServerControlImpl extends ConsumerWidget {
  const ServerControlImpl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetServer(
      errorBuilder: (_, __) {
        return const SizedBox.shrink();
      },
      loadingBuilder: () => CLLoader.hide(
        debugMessage: 'GetServer',
      ),
      builder: (server) {
        return GetDownloaderStatus(
          errorBuilder: (_, __) {
            return const SizedBox.shrink();
          },
          loadingBuilder: () => CLLoader.hide(
            debugMessage: 'GetDownloaderStatus',
          ),
          builder: (downloaderStatus) {
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
                    Expanded(
                      child: Row(
                        children: [
                          ...[
                            SpeedDial(
                              overlayOpacity: 0,
                              elevation: 0,
                              buttonSize: const Size(30, 30),
                              children: [
                                if (!server.isOffline)
                                  if (!server.workingOffline)
                                    SpeedDialChild(
                                      onTap: () {
                                        ref
                                            .read(serverProvider.notifier)
                                            .workOffline();
                                      },
                                      labelWidget: const SpeedDialChildWrapper(
                                        child: WorkOffline(),
                                      ),
                                    )
                                  else
                                    SpeedDialChild(
                                      onTap: () {
                                        ref
                                            .read(serverProvider.notifier)
                                            .goOnline();
                                      },
                                      labelWidget: const SpeedDialChildWrapper(
                                        child: GoOnline(),
                                      ),
                                    ),
                                if (server.canSync)
                                  SpeedDialChild(
                                    onTap: () {
                                      ref
                                          .read(serverProvider.notifier)
                                          .manualSync();
                                    },
                                    labelWidget: const SyncServer(),
                                  ),
                              ],
                              switchLabelPosition: true,
                              activeIcon: clIcons.closeFullscreen,
                              child: Image.asset(
                                'assets/icon/cloud_on_lan_128px_color.png',
                              ),
                            ),
                            if (server.isSyncing)
                              const CircularProgressIndicator.adaptive(),
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
                          ].map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(left: 16),
                              child: e,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const ChangeMonitor(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class ServerSpeedDialImpl extends ConsumerWidget {
  const ServerSpeedDialImpl({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetServer(
      loadingBuilder: () => CLLoader.hide(
        debugMessage: 'GetServer',
      ),
      errorBuilder: (_, __) => const SizedBox.shrink(),
      builder: (server) {
        if (server.identity == null) {
          return const SizedBox.shrink();
        }
        return Stack(
          alignment: AlignmentDirectional.center,
          children: [
            SpeedDial(
              overlayOpacity: 0,
              elevation: 0,
              //buttonSize: const Size(40, 40),
              backgroundColor: ShadTheme.of(context)
                  .colorScheme
                  .background
                  .withValues(alpha: 0.5),
              //Theme.of(context).colorScheme.primaryContainer.withAlpha(200),
              foregroundColor: ShadTheme.of(context).colorScheme.foreground,

              children: [
                if (!server.isOffline)
                  if (!server.workingOffline)
                    SpeedDialChild(
                      onTap: () {
                        ref.read(serverProvider.notifier).workOffline();
                      },
                      labelWidget: const SpeedDialChildWrapper(
                        child: WorkOffline(),
                      ),
                    )
                  else
                    SpeedDialChild(
                      onTap: () {
                        ref.read(serverProvider.notifier).goOnline();
                      },
                      labelWidget: const SpeedDialChildWrapper(
                        child: GoOnline(),
                      ),
                    ),
                if (server.canSync)
                  SpeedDialChild(
                    onTap: () {
                      ref.read(serverProvider.notifier).manualSync();
                    },
                    labelWidget: const SyncServer(),
                  ),
              ],
              switchLabelPosition: true,
              activeChild: ShadAvatar(
                clIcons.closeFullscreen,
              ),
              child: const ShadAvatar(
                'assets/icon/cloud_on_lan_128px_color.png',
              ),
            ),
            if (server.isSyncing)
              const SizedBox.square(
                dimension: 56,
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
          ],
        );
      },
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
