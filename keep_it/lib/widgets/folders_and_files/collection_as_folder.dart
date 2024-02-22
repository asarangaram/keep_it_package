import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/widgets/editors/collection_editor.dart';
import 'package:store/store.dart';

import '../wrap_standard_quick_menu.dart';

class CollectionAsFolder extends ConsumerWidget {
  const CollectionAsFolder({
    required this.collection,
    required this.quickMenuScopeKey,
    super.key,
  });
  final Collection collection;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return WrapStandardQuickMenu(
      quickMenuScopeKey: quickMenuScopeKey,
      onEdit: () async {
        final res =
            await CollectionEditor.popupDialog(context, collection: collection);
        if (res != null) {
          final (updated, tags) = res;

          final newTags = await ref
              .read(tagsProvider(null).notifier)
              .upsertTags(tags.where((e) => e.id == null));
          final existingTags = tags.where((e) => e.id != null);
          await ref.read(collectionsProvider(null).notifier).upsertCollection(
                updated,
                [...newTags, ...existingTags].map((e) => e.id!).toList(),
              );
        }

        return true;
      },
      onDelete: () async {
        // delete all the items in the collection !!

        await ref
            .read(collectionsProvider(null).notifier)
            .deleteCollection(collection);
        return true;
      },
      onTap: () async {
        unawaited(
          context.push(
            '/items/${collection.id}',
          ),
        );
        return true;
      },
      child: Column(
        children: [
          Flexible(
            child: PreviewGenerator(
              collection: collection,
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
  }
}

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.collection,
    super.key,
  });
  final Collection collection;

  @override
  Widget build(BuildContext context) {
    return LoadItems(
      collectionID: collection.id!,
      buildOnData: (Items items) {
        return CLAspectRationDecorated(
          borderRadius: const BorderRadius.all(Radius.circular(16)),
          child: CLMediaCollage.byMatrixSize(
            items.entries,
            hCount: 2,
            vCount: 2,
            itemBuilder: (context, index) => CLMediaPreview(
              media: items.entries[index],
              keepAspectRatio: false,
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
