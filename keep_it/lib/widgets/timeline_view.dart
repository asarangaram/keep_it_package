import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:share_plus/share_plus.dart';
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
          tagPrefix: parentIdentifier,
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
          selectionActions: (context, items) {
            return [
              CLMenuItem(
                title: 'Delete',
                icon: Icons.delete,
                onTap: () async {
                  final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return ConfirmAction(
                            title: 'Confirm delete',
                            message: 'Are you sure you want to delete '
                                '${items.length} items?',
                            child: null,
                            onConfirm: ({required confirmed}) =>
                                Navigator.of(context).pop(confirmed),
                          );
                        },
                      ) ??
                      false;
                  if (confirmed) {
                    await dbManager.deleteMediaMultiple(
                      items,
                      onDeleteFile: (f) async => f.deleteIfExists(),
                    );
                  }
                  return confirmed;
                },
              ),
              CLMenuItem(
                title: 'Move',
                icon: MdiIcons.imageMove,
                onTap: () async {
                  final result = await context.push<bool>(
                    '/move?ids=${items.map((e) => e.id).join(',')}',
                  );

                  return result;
                },
              ),
              CLMenuItem(
                title: 'Share',
                icon: MdiIcons.shareAll,
                onTap: () async {
                  final box = context.findRenderObject() as RenderBox?;
                  final files = items.map((e) => XFile(e.path)).toList();
                  final shareResult = await Share.shareXFiles(
                    files,
                    // text: 'Share from KeepIT',
                    subject: 'Media from KeepIt',
                    sharePositionOrigin:
                        box!.localToGlobal(Offset.zero) & box.size,
                  );
                  return switch (shareResult.status) {
                    ShareResultStatus.dismissed => false,
                    ShareResultStatus.unavailable => false,
                    ShareResultStatus.success => true,
                  };
                },
              ),
            ];
          },
        );
      },
    );
  }
}
