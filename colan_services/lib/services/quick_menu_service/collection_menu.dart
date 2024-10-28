import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:pull_down_button/pull_down_button.dart';
import 'package:store/store.dart';

class CollectionMenu extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuHeader(
          title: collection.label,
          leadingBuilder: (context, constraints) {
            return SizedBox.square(
              dimension: 24,
              child: collection.serverUID == null
                  ? Image.asset('assets/icon/on_device.png')
                  : Image.asset(
                      'assets/icon/cloud_on_lan_128px_color.png',
                    ),
            );
          },
        ),
        //if (downloadStatusWidget != null)
        PullDownMenuTitle(
          title: downloadStatusWidget ??
              const CLText.tiny('Unknown download Status'),
        ),
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
              iconColor: Colors.red,
            ),
            if (collection.serverUID == null)
              PullDownMenuItem(
                title: 'Upload',
                onTap: onUpload,
                icon: Icons.upload,
              )
            else if (collection.haveItOffline)
              if (isSyncing)
                const PullDownMenuItem(
                  onTap: null,
                  title: 'Syncing',
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                )
              else
                const PullDownMenuItem(
                  onTap: null,
                  title: 'Synced',
                  icon: Icons.check_circle,
                  iconColor: Colors.green,
                )
            else
              PullDownMenuItem(
                onTap: onKeepOffline,
                enabled: onKeepOffline != null,
                title: 'Sync',
                icon: Icons.sync,
                iconColor: Colors.red,
              ),
          ],
        ),
        PullDownMenuActionsRow.medium(
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
              icon: Icons.sync_alt,
            ),
            PullDownMenuItem(
              onTap: onShare,
              enabled: onShare != null,
              title: 'Share',
              icon: clIcons.imageShare,
            ),
          ],
        ),
        if (collection.serverUID != null) ...[
          PullDownMenuItem(
            title: collection.haveItOffline
                ? 'Remove Downloads'
                : ' Have it Offline',
            subtitle: collection.haveItOffline
                ? 'delete local media. Still available online'
                : 'download the media to device',
            onTap: collection.haveItOffline ? onDeleteLocalCopy : onKeepOffline,
            enabled: collection.haveItOffline
                ? onDeleteLocalCopy != null
                : onKeepOffline != null,
            icon: collection.haveItOffline
                ? Icons.check_box_outlined
                : Icons.check_box_outline_blank,
          ),
          PullDownMenuItem(
            title: 'Delete Server Copy',
            subtitle: 'Delete in server. ' "can't access from other devices",
            onTap: onDeleteServerCopy,
            icon: Icons.cloud_off,
            iconColor: Colors.red,
          ),
        ],
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
