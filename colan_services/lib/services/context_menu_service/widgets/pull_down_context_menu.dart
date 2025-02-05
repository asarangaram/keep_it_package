import 'package:colan_services/extensions/cl_menu_item.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_down_button/pull_down_button.dart';

import '../models/context_menu_items.dart';

class PullDownContextMenu extends ConsumerWidget {
  const PullDownContextMenu({
    required this.child,
    super.key,
    this.onTap,
    this.contextMenu,
  });

  final Widget child;
  final Future<bool?> Function()? onTap;
  final CLContextMenu? contextMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contextMenu == null) {
      return GestureDetector(
        onTap: onTap,
        child: child,
      );
    } else {
      final menu = contextMenu!;
      return PullDownButton(
        itemBuilder: (context) => [
          PullDownMenuHeader(
            title: menu.name,
            leadingBuilder: (context, constraints) {
              return SizedBox.square(
                dimension: 24,
                child: Image.asset(menu.logoImageAsset),
              );
            },
          ),
          if (menu.onDelete.onTap != null || menu.onMove.onTap != null)
            PullDownMenuActionsRow.medium(
              items: [
                menu.onDelete.pullDownMenuItem,
                menu.onMove.pullDownMenuItem,
              ],
            ),
          if (menu.onEdit.onTap != null ||
              menu.onPin.onTap != null ||
              menu.onShare.onTap != null)
            PullDownMenuActionsRow.small(
              items: [
                menu.onEdit.pullDownMenuItem,
                menu.onPin.pullDownMenuItem,
                menu.onShare.pullDownMenuItem,
              ],
            ),
          if (menu.onDeleteLocalCopy.onTap != null)
            menu.onDeleteLocalCopy.pullDownMenuItem,
          if (menu.onKeepOffline.onTap != null)
            menu.onKeepOffline.pullDownMenuItem,
          PullDownMenuTitle(
            title: MapInfo(
              menu.infoMap,
              title: 'Details',
            ),
          ),
        ],
        buttonAnchor: PullDownMenuAnchor.center,
        buttonBuilder: (context, showMenu) {
          return GestureDetector(
            onTap: onTap,
            onSecondaryTap: showMenu,
            onLongPress: showMenu,
            child: child,
          );
        },
      );
    }
  }
}

class MapInfo extends StatefulWidget {
  const MapInfo(
    this.map, {
    super.key,
    this.title,
  });
  final Map<String, dynamic> map;
  final String? title;

  @override
  State<MapInfo> createState() => _MapInfoState();
}

class _MapInfoState extends State<MapInfo> {
  bool show = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Table(
          border: TableBorder.all(),
          children: [
            TableRow(
              children: [
                TableCell(
                  verticalAlignment: TableCellVerticalAlignment.middle,
                  child: Text(
                    widget.title ?? 'Details:',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                TableCell(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        show = !show;
                      });
                    },
                    child: Align(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Text(
                          show ? 'Hide' : 'show',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (show)
              for (final entry in widget.map.entries)
                TableRow(
                  children: [
                    TableCell(child: PaddedText(entry.key)),
                    TableCell(child: PaddedText(entry.value.toString())),
                  ],
                ),
          ],
        ),
      ],
    );
  }
}

class PaddedText extends StatelessWidget {
  const PaddedText(this.text, {super.key, this.style});
  final String text;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        text,
        textAlign: TextAlign.left,
        style: style,
      ),
    );
  }
}

class OfflineSyncedMenuOption extends StatelessWidget {
  const OfflineSyncedMenuOption({
    super.key,
  });
  static Widget? cache;

  @override
  Widget build(BuildContext context) {
    return cache ??= const Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: ' Any changed into this collection '
                      'will be synced when you go online',
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: CLIcon.tiny(
            Icons.drive_folder_upload_outlined,
          ),
        ),
      ],
    );
  }
}

class UploadMenuOption extends StatelessWidget {
  const UploadMenuOption({
    super.key,
  });
  static Widget? cache;

  @override
  Widget build(BuildContext context) {
    return cache ??= const Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Tap here',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(
                  text: 'Tap here to upload and preserve '
                      'this on your local cloud',
                ),
              ],
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: CLIcon.tiny(
            Icons.drive_folder_upload_outlined,
          ),
        ),
      ],
    );
  }
}

class SyncMenuOption extends StatelessWidget {
  const SyncMenuOption({
    super.key,
  });
  static Widget? cache;

  @override
  Widget build(BuildContext context) {
    return cache ??= const Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'This Collection is avaiable online. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'Tap here ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(text: 'to download and keep in this device'),
              ],
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: SizedBox.square(
            dimension: 30,
            child: FittedBox(
              child: CLIconLabelled.small(
                Icons.check_box_outline_blank,
                'Not\nSyncing',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class UnsyncMenuOption extends StatelessWidget {
  const UnsyncMenuOption({
    super.key,
  });
  static Widget? cache;

  @override
  Widget build(BuildContext context) {
    return cache ??= const Row(
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'This Collection is synced to this device. ',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: 'Tap here ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                TextSpan(text: 'to remove the downloads and freeup space'),
              ],
            ),
            textAlign: TextAlign.left,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8),
          child: SizedBox.square(
            dimension: 30,
            child: FittedBox(
              child: CLIconLabelled.tiny(
                Icons.check_box_outlined,
                'Syncing',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class EntityMetaData extends ConsumerWidget {
  const EntityMetaData({
    required this.child,
    super.key,
    this.contextMenu,
  });

  final Widget child;

  final CLContextMenu? contextMenu;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (contextMenu?.infoMap == null) {
      return const SizedBox.shrink();
    }
    final menu = contextMenu!;

    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          title: menu.name,
          leadingBuilder: (context, constraints) {
            return SizedBox.square(
              dimension: 24,
              child: Image.asset(menu.logoImageAsset),
            );
          },
        ),
        PullDownMenuTitle(
          title: MapInfo(
            menu.infoMap,
            title: 'Details',
          ),
        ),
      ],
      buttonAnchor: PullDownMenuAnchor.center,
      buttonBuilder: (context, showMenu) {
        return GestureDetector(
          onTap: showMenu,
          child: child,
        );
      },
    );
  }
}
