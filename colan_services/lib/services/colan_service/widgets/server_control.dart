import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import '../providers/server.dart';
import 'downloader_progressbar.dart';

class ServerControl extends ConsumerWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                SpeedDialChild(
                  labelWidget: SpeedDialIcon(
                    clIcons.syncIcons.syncIconData,
                    'Sync With Server',
                  ),
                ),
                SpeedDialChild(
                  labelWidget: SpeedDialIcon(
                    clIcons.syncIcons.disconnectIconData,
                    'Work Offline',
                  ),
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

class SpeedDialIcon extends StatelessWidget {
  const SpeedDialIcon(
    this.iconData,
    this.label, {
    super.key,
    this.backgroundColor,
    this.foregroudColor,
  });
  final IconData iconData;
  final String label;
  final Color? backgroundColor;
  final Color? foregroudColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32),
      alignment: Alignment.centerLeft,
      width: 200,
      height: 40,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: LabeledIconHorizontal(
          iconData,
          label,
          backgroundColor: backgroundColor,
          foregroudColor: foregroudColor,
        ),
      ),
    );
  }
}

class LabeledIconHorizontal extends StatelessWidget {
  const LabeledIconHorizontal(
    this.iconData,
    this.label, {
    this.backgroundColor,
    this.foregroudColor,
    super.key,
  });

  final Color? backgroundColor;
  final IconData iconData;
  final String label;
  final Color? foregroudColor;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor ??
            Theme.of(context)
                .colorScheme
                .primary, // ElevatedButton background color
        borderRadius:
            BorderRadius.circular(8), // Rounded corners like ElevatedButton
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.2), // Slight shadow to simulate elevation
            blurRadius: 4,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          mainAxisSize:
              MainAxisSize.min, // Shrinks the container to the content size
          children: [
            Icon(iconData, color: Colors.white), // Icon with white color
            const SizedBox(width: 8), // Space between icon and text
            Text(
              label,
              style: TextStyle(
                color: foregroudColor ?? Colors.white,
              ), // White text to match the button style
            ),
          ],
        ),
      ),
    );
  }
}
