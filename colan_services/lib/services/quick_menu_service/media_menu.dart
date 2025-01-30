import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:store/store.dart';

import '../basic_page_service/widgets/page_manager.dart';
import '../media_wizard_service/media_wizard_service.dart';

@immutable
class ContextMenuItems {
  const ContextMenuItems({
    required this.onEdit,
    required this.onMove,
    required this.onShare,
    required this.onPin,
    required this.onDelete,
    required this.onDeleteLocalCopy,
    required this.onKeepOffline,
    required this.onUpload,
    required this.onDeleteServerCopy,
  });
  factory ContextMenuItems.ofMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
    required Collection parentCollection,
    required bool hasOnlineService,
    required StoreUpdater theStore,
    ValueGetter<Future<bool?> Function()?>? onEdit,
    ValueGetter<Future<bool?> Function()?>? onMove,
    ValueGetter<Future<bool?> Function()?>? onShare,
    ValueGetter<Future<bool?> Function()?>? onPin,
    ValueGetter<Future<bool?> Function()?>? onDelete,
    ValueGetter<Future<bool?> Function()?>? onDeleteLocalCopy,
    ValueGetter<Future<bool?> Function()?>? onKeepOffline,
    ValueGetter<Future<bool?> Function()?>? onUpload,
    ValueGetter<Future<bool?> Function()?>? onDeleteServerCopy,
  }) {
    final ac = ActionControl.onGetMediaActionControl(media);

    final onMove0 = ac.onMove(
      onMove != null
          ? onMove()
          : () => MediaWizardService.openWizard(
                context,
                ref,
                CLSharedMedia(
                  entries: [media],
                  type: UniversalMediaSource.move,
                ),
              ),
    );

    final onEdit0 = ac.onEdit(
      onEdit != null
          ? onEdit()
          : () async {
              await PageManager.of(context).openEditor(media);
              return true;
            },
    );

    final onShare0 = ac.onShare(
      onShare != null
          ? onShare()
          : () => theStore.mediaUpdater.share(context, [media]),
    );
    final onDelete0 = ac.onDelete(
      onDelete != null
          ? onDelete()
          : () async => theStore.mediaUpdater.delete(media.id!),
    );
    final onPin0 = ac.onPin(
      onPin != null
          ? onPin()
          : media.isMediaLocallyAvailable
              ? () async => theStore.mediaUpdater.pinToggleMultiple(
                    {media.id},
                    onGetPath: (media) {
                      if (media.isMediaLocallyAvailable) {
                        return theStore.directories.getMediaAbsolutePath(media);
                      }

                      return null;
                    },
                  )
              : null,
    );
    final canSync = hasOnlineService;
    final canDeleteLocalCopy = canSync &&
        parentCollection.haveItOffline &&
        media.hasServerUID &&
        media.isMediaCached;
    final haveItOffline = switch (media.haveItOffline) {
      null => parentCollection.haveItOffline,
      true => true,
      false => false
    };
    final canDownload =
        canSync && media.hasServerUID && !media.isMediaCached && haveItOffline;

    final onDeleteLocalCopy0 = canDeleteLocalCopy
        ? onDeleteLocalCopy != null
            ? onDeleteLocalCopy()
            : () async =>
                ref.read(serverProvider.notifier).onDeleteMediaLocalCopy(media)
        : null;
    final onKeepOffline0 = canDownload
        ? onKeepOffline != null
            ? onKeepOffline()
            : () async =>
                ref.read(serverProvider.notifier).onKeepMediaOffline(media)
        : null;

    final onUpload0 = onUpload != null ? onUpload() : null;
    final onDeleteServerCopy0 =
        onDeleteServerCopy != null ? onDeleteServerCopy() : null;

    return ContextMenuItems(
      onEdit:
          CLMenuItem(title: 'Edit', icon: clIcons.imageEdit, onTap: onEdit0),
      onMove:
          CLMenuItem(title: 'Move', icon: clIcons.imageMove, onTap: onMove0),
      onShare:
          CLMenuItem(title: 'Share', icon: clIcons.imageShare, onTap: onShare0),
      onPin: CLMenuItem(
        title: media.pin != null ? 'Remove Pin' : 'Pin',
        icon: media.pin != null ? clIcons.unPin : clIcons.pin,
        onTap: onPin0,
      ),
      onDelete: CLMenuItem(
        title: 'Delete',
        icon: clIcons.imageDelete,
        onTap: onDelete0,
      ),
      onDeleteLocalCopy: CLMenuItem(
        title: 'Remove downloads',
        icon: Icons.download_done_sharp,
        onTap: onDeleteLocalCopy0,
      ),
      onKeepOffline: CLMenuItem(
        title: 'Download',
        icon: Icons.download_sharp,
        onTap: onKeepOffline0,
      ),
      onUpload:
          CLMenuItem(title: 'Upload', icon: Icons.upload, onTap: onUpload0),
      onDeleteServerCopy: CLMenuItem(
        title: 'Permanently Delete',
        icon: Icons.remove,
        onTap: onDeleteServerCopy0,
      ),
    );
  }
  final CLMenuItem onEdit;
  final CLMenuItem onMove;
  final CLMenuItem onShare;
  final CLMenuItem onPin;
  final CLMenuItem onDelete;
  final CLMenuItem onDeleteLocalCopy;
  final CLMenuItem onKeepOffline;
  final CLMenuItem onUpload;
  final CLMenuItem onDeleteServerCopy;
}

extension MenuItemToUI on CLMenuItem {
  PullDownMenuItem get pullDownMenuItem {
    return PullDownMenuItem(
      onTap: onTap,
      enabled: onTap != null,
      title: title,
      icon: icon,
      //iconColor: Colors.red,
      //isDestructive: true,
    );
  }
}

class MediaMenu extends ConsumerWidget {
  const MediaMenu({
    required this.child,
    required this.media,
    required this.parentCollection,
    super.key,
    this.onTap,
    this.contextMenu,
  });
  final CLMedia media;
  final Collection parentCollection;
  final Widget child;
  final ContextMenuItems? contextMenu;

  final Future<bool?> Function()? onTap;

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
            title: media.name,
            leadingBuilder: (context, constraints) {
              return SizedBox.square(
                dimension: 24,
                child: media.serverUID == null
                    ? Image.asset('assets/icon/not_on_server.png')
                    : Image.asset(
                        'assets/icon/cloud_on_lan_128px_color.png',
                      ),
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
              media.toMapForDisplay(),
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
