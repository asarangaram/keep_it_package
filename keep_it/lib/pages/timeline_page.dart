// ignore_for_file: unused_element

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../providers/gallery_group_provider.dart';
import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/media_as_file.dart';

class CollectionTimeLinePage extends ConsumerWidget {
  const CollectionTimeLinePage({required this.collectionId, super.key});

  final int collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => GetCollection(
        id: collectionId,
        buildOnData: (collection) => GetMediaByCollectionId(
          collectionId: collectionId,
          buildOnData: (items) => TimeLineView(
            label: collection?.label ?? 'All Media',
            items: items,
            tagPrefix: 'Gallery View Media CollectionId: ${collection?.id}',
            onPickFiles: () async => onPickFiles(
              context,
              ref,
              collection: collection,
            ),
          ),
        ),
      );
}

class TimeLineView extends ConsumerWidget {
  const TimeLineView({
    required this.label,
    required this.tagPrefix,
    required this.items,
    this.onPickFiles,
    super.key,
  });

  final String label;
  final String tagPrefix;
  final List<CLMedia> items;
  final void Function()? onPickFiles;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final galleryGroups = ref.watch(groupedItemsProvider(items));

    return GetDBManager(
      builder: (dbManager) {
        return CLSimpleGalleryView(
          key: ValueKey(label),
          title: label,
          tagPrefix: tagPrefix,
          columns: 4,
          galleryMap: galleryGroups,
          emptyState: const EmptyState(),
          itemBuilder: (context, item, {required quickMenuScopeKey}) => Hero(
            tag: '/item/${item.collectionId}/${item.id}',
            child: MediaAsFile(
              media: item,
              quickMenuScopeKey: quickMenuScopeKey,
            ),
          ),
          onPickFiles: onPickFiles,
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
            ];
          },
        );
      },
    );
  }
}
