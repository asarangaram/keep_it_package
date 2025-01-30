import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import '../../media_wizard_service/media_wizard_service.dart';

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
