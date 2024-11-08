import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:store/store.dart';

import '../basic_page_service/navigators.dart';
import '../incoming_media_service/models/cl_shared_media.dart';
import '../media_view_service/models/action_control.dart';
import '../media_wizard_service/media_wizard_service.dart';

class MediaMenu extends ConsumerWidget {
  const MediaMenu({
    required this.child,
    required this.media,
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
  final CLMedia media;

  final Widget child;
  final ValueGetter<Future<bool?> Function()?>? onEdit;
  final Widget? downloadStatusWidget;

  final ValueGetter<Future<bool?> Function()?>? onMove;
  final ValueGetter<Future<bool?> Function()?>? onShare;
  final Future<bool?> Function()? onTap;
  final ValueGetter<Future<bool?> Function()?>? onPin;

  final ValueGetter<Future<bool?> Function()?>? onDelete;
  final ValueGetter<Future<bool?> Function()?>? onDeleteLocalCopy;
  final ValueGetter<Future<bool?> Function()?>? onKeepOffline;

  final ValueGetter<Future<bool?> Function()?>? onUpload;
  final ValueGetter<Future<bool?> Function()?>? onDeleteServerCopy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStoreUpdater(
      builder: (theStore) {
        final canSync =
            ref.watch(serverProvider.select((server) => server.canSync));
        final ac = AccessControlExt.onGetMediaActionControl(media);

        final onMove = ac.onMove(
          this.onMove != null
              ? this.onMove!()
              : () => MediaWizardService.openWizard(
                    context,
                    ref,
                    CLSharedMedia(
                      entries: [media],
                      type: UniversalMediaSource.move,
                    ),
                  ),
        );

        final onEdit = ac.onEdit(
          this.onEdit != null
              ? this.onEdit!()
              : () async {
                  await Navigators.openEditor(
                    context,
                    ref,
                    media,
                  );
                  return true;
                },
        );

        final onShare = ac.onShare(
          this.onShare != null
              ? this.onShare!()
              : () => theStore.mediaUpdater.share(context, [media]),
        );
        final onDelete = ac.onDelete(
          this.onDelete != null
              ? this.onDelete!()
              : () async => theStore.mediaUpdater.delete(media.id!),
        );
        final onPin = ac.onPin(
          this.onPin != null
              ? this.onPin!()
              : () async => theStore.mediaUpdater.pinToggle(media.id!),
        );

        return GetCollection(
          id: media.collectionId,
          loadingBuilder: CircularProgressIndicator.new,
          errorBuilder: (e, st) => Text(e.toString()),
          builder: (collection0) {
            final collection = collection0!;

            final canDeleteLocalCopy = canSync &&
                collection.haveItOffline &&
                media.hasServerUID &&
                media.isMediaCached;
            final canDownload = canSync &&
                collection.haveItOffline &&
                media.hasServerUID &&
                !media.isMediaCached &&
                media.haveItOffline != null &&
                (!media.haveItOffline!);
            final onDeleteLocalCopy = canDeleteLocalCopy
                ? this.onDeleteLocalCopy != null
                    ? this.onDeleteLocalCopy!()
                    : () async => ref
                        .read(serverProvider.notifier)
                        .onDeleteMediaLocalCopy(media)
                : null;
            final onKeepOffline = canDownload
                ? this.onKeepOffline != null
                    ? this.onKeepOffline!()
                    : () async => ref
                        .read(serverProvider.notifier)
                        .onKeepMediaOffline(media)
                : null;
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

                //if (downloadStatusWidget != null)

                PullDownMenuActionsRow.medium(
                  items: [
                    PullDownMenuItem(
                      onTap: onDelete,
                      enabled: onDelete != null,
                      title: 'Delete',
                      icon: clIcons.imageDelete,
                      //iconColor: Colors.red,
                      isDestructive: true,
                    ),
                    PullDownMenuItem(
                      onTap: onMove,
                      enabled: onMove != null,
                      title: 'Move',
                      icon: clIcons.imageMove,
                    ),
                  ],
                ),
                if (onEdit != null || onPin != null || onShare != null)
                  PullDownMenuActionsRow.small(
                    items: [
                      PullDownMenuItem(
                        onTap: onEdit,
                        enabled: onEdit != null,
                        title: 'Edit',
                        icon: clIcons.imageEdit,
                      ),
                      PullDownMenuItem(
                        onTap: onPin,
                        enabled: onPin != null,
                        title: 'Pin',
                        icon: clIcons.pinAll,
                      ),
                      PullDownMenuItem(
                        onTap: onShare,
                        enabled: onShare != null,
                        title: 'Share',
                        icon: clIcons.imageShare,
                      ),
                    ],
                  ),

                if (canDeleteLocalCopy)
                  PullDownMenuItem(
                    onTap: onDeleteLocalCopy,
                    title: 'Remove downloads',
                    subtitle: 'Freeup space on this device',
                    icon: Icons.download_done_sharp,
                  ),
                if (canDownload)
                  PullDownMenuItem(
                    onTap: onKeepOffline,
                    title: 'Download',
                    subtitle: 'To view offline',
                    icon: Icons.download_sharp,
                  ),

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
          },
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
