import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:store/store.dart';

class CollectionMenu extends ConsumerWidget {
  const CollectionMenu({
    required this.child,
    required this.collection,
    required this.isSyncing,
    super.key,
    this.onDelete,
    this.onEdit,
    this.onMove,
    this.onShare,
    this.onTap,
    this.onPin,
    this.onUpload,
    this.onKeepOffline,
    this.onDeleteLocalCopy,
    this.onDeleteServerCopy,
    this.downloadStatusWidget,
  });
  final Collection collection;
  final Widget child;
  final Future<bool?> Function()? onEdit;
  final Widget? downloadStatusWidget;

  final Future<bool?> Function()? onMove;
  final Future<bool?> Function()? onShare;
  final Future<bool?> Function()? onTap;
  final Future<bool?> Function()? onPin;
  final Future<bool?> Function()? onUpload;
  final Future<bool?> Function()? onDelete;
  final Future<bool?> Function()? onDeleteLocalCopy;
  final Future<bool?> Function()? onDeleteServerCopy;
  final Future<bool?> Function()? onKeepOffline;
  final bool isSyncing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          title: collection.label,
          leadingBuilder: (context, constraints) {
            return SizedBox.square(
              dimension: 24,
              child: collection.serverUID == null
                  ? Image.asset('assets/icon/not_on_server.png')
                  : Image.asset(
                      'assets/icon/cloud_on_lan_128px_color.png',
                    ),
            );
          },
        ),

        //if (downloadStatusWidget != null)

        PullDownMenuActionsRow.medium(
          items: [
            PullDownMenuItem(
              onTap: onEdit,
              enabled: onEdit != null,
              title: 'Edit',
              icon: clIcons.imageEdit,
            ),
            PullDownMenuItem(
              onTap: onDelete,
              enabled: onDelete != null,
              title: 'Delete',
              icon: clIcons.imageDelete,
              //iconColor: Colors.red,
              isDestructive: true,
            ),
            PullDownMenuItem(
              onTap: onShare,
              enabled: onShare != null,
              title: 'Share',
              icon: clIcons.imageShare,
            ),
          ],
        ),
        //if (onMove != null || onPin != null)
        PullDownMenuActionsRow.small(
          items: [
            PullDownMenuItem(
              onTap: onMove,
              enabled: onMove != null,
              title: 'Move',
              icon: clIcons.imageMove,
            ),
            PullDownMenuItem(
              onTap: onPin,
              enabled: onPin != null,
              title: 'Pin',
              icon: clIcons.pinAll,
            ),
          ],
        ),

        if (canSync)
          if (!collection.hasServerUID)
            PullDownMenuItem(
              onTap: onUpload,
              title: 'Upload',
              icon: Icons.upload_sharp,
            )
          else if (!collection.haveItOffline)
            PullDownMenuItem(
              onTap: onKeepOffline,
              title: 'Download',
              subtitle: 'To view offline',
              icon: Icons.download_sharp,
            )
          else
            PullDownMenuItem(
              onTap: onDeleteLocalCopy,
              title: 'Remove downloads',
              subtitle: 'Freeup space on this device',
              icon: Icons.download_done_sharp,
            )
        else if (collection.hasServerUID && collection.haveItOffline)
          PullDownMenuItem(
            onTap: onDeleteLocalCopy,
            title: 'Remove downloads',
            subtitle: 'Freeup space on this device',
            icon: Icons.download_done_sharp,
          ),
        PullDownMenuTitle(
          title: MapInfo(
            collection.toMapForDisplay(),
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
