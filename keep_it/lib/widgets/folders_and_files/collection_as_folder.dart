import 'dart:async';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/collection_editor.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Widget Function(CLMedia media) getPreview;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBManager(
      builder: (dbManager) {
        return WrapStandardQuickMenu(
          quickMenuScopeKey: quickMenuScopeKey,
          onEdit: () async {
            final res = await CollectionEditor.popupDialog(
              context,
              collection: collection,
            );
            if (res != null) {
              final (collection) = res;
              await dbManager.upsertCollection(
                collection: collection,
              );

              await ref
                  .read(notificationMessageProvider.notifier)
                  .push('Updated');
            }

            return true;
          },
          onDelete: () async {
            final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) {
                    return CLConfirmAction(
                      title: 'Confirm Delete',
                      message: 'Are you sure you want to delete '
                          '"${collection.label}" and its content?',
                      child: null,
                      onConfirm: ({required confirmed}) =>
                          Navigator.of(context).pop(confirmed),
                    );
                  },
                ) ??
                false;

            if (confirmed) {
              await dbManager.deleteCollection(
                collection,
                onDeleteFile: (file) async {
                  if (file.existsSync()) {
                    file.deleteSync();
                  }
                },
              );
            }
            return confirmed;
          },
          onTap: () async {
            await context.push(
              '/items_by_collection/${collection.id}',
            );
            return true;
          },
          child: Column(
            children: [
              Flexible(
                child: CollectionPreviewGenerator(
                  collection: collection,
                  getPreview: getPreview,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  collection.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> deleteCollection(
    DBManager dbManager,
    Collection collection,
  ) async {}
}

class CollectionPreviewGenerator extends StatelessWidget {
  const CollectionPreviewGenerator({
    required this.collection,
    required this.getPreview,
    super.key,
  });
  final Collection collection;
  final Widget Function(CLMedia media) getPreview;

  @override
  Widget build(BuildContext context) {
    return GetMediaByCollectionId(
      collectionId: collection.id,
      buildOnData: (items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            items,
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => getPreview(
              items[index],
            ),
            whenNopreview: Center(
              child: CLText.veryLarge(
                collection.label.characters.first,
              ),
            ),
          ),
        );
      },
    );
  }
}
