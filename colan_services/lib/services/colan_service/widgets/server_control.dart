import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'downloader_progressbar.dart';

class ServerControl extends StatelessWidget {
  const ServerControl({super.key});

  @override
  Widget build(BuildContext context) {
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
            const SizedBox.square(
              dimension: 30,
              child: DownloaderProgressPie(),
            ),
            const SizedBox.square(
              dimension: 30,
              child: ActiveDownloadIndicator(),
            ),
            const Spacer(),
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
  });
  final IconData iconData;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 32),
      alignment: Alignment.centerLeft,
      width: 200,
      height: 40,
      child: FittedBox(
        fit: BoxFit.fitHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Theme.of(context)
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
                  style: const TextStyle(
                    color: Colors.white,
                  ), // White text to match the button style
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
