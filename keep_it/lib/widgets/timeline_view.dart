import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/models/media_handler.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../providers/gallery_group_provider.dart';
import 'empty_state.dart';
import 'folders_and_files/media_as_file.dart';

class TimeLineView extends ConsumerWidget {
  const TimeLineView({
    required this.label,
    required this.parentIdentifier,
    required this.items,
    required this.onTapMedia,
    this.onPickFiles,
    this.onCameraCapture,
    super.key,
  });

  final String label;
  final String parentIdentifier;
  final List<CLMedia> items;
  final Future<bool?> Function(int id, {required String parentIdentifier})
      onTapMedia;
  final void Function(BuildContext context)? onPickFiles;
  final void Function()? onCameraCapture;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryGroups = ref.watch(groupedItemsProvider(items));

    return GetDBManager(
      builder: (dbManager) {
        return CLSimpleGalleryView(
          key: ValueKey(label),
          title: label,
          identifier: parentIdentifier,
          columns: 4,
          galleryMap: galleryGroups,
          emptyState: const EmptyState(),
          itemBuilder: (context, item, {required quickMenuScopeKey}) => Hero(
            tag: '$parentIdentifier /item/${item.id}',
            child: MediaAsFile(
              media: item,
              onTap: () =>
                  onTapMedia(item.id!, parentIdentifier: parentIdentifier),
              quickMenuScopeKey: quickMenuScopeKey,
            ),
          ),
          onPickFiles: onPickFiles,
          onCameraCapture: onCameraCapture,
          onRefresh: () async => ref.invalidate(dbManagerProvider),
          selectionActions: (context, items0) {
            final mediaHandler =
                MediaHandler.multiple(media: items0, dbManager: dbManager);
            return [
              CLMenuItem(
                title: 'Delete',
                icon: Icons.delete,
                onTap: () => mediaHandler.delete(context, ref),
              ),
              CLMenuItem(
                title: 'Move',
                icon: MdiIcons.imageMove,
                onTap: () => mediaHandler.move(context, ref),
              ),
              CLMenuItem(
                title: 'Share',
                icon: MdiIcons.shareAll,
                onTap: () => mediaHandler.share(context, ref),
              ),
              CLMenuItem(
                title: 'Pin',
                icon: MdiIcons.pin,
                onTap: () => mediaHandler.togglePin(context, ref),
              ),
            ];
          },
        );
      },
    );
  }
}
