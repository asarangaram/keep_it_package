import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../controls/is_preview_square.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';
import '../widgets/provider_wraps/cl_media_gridview.dart';
import '../widgets/tag_preview.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({required this.tagId, super.key});

  final int? tagId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => CLFullscreenBox(
        child: CLBackground(
          child: LoadCollections(
            tagID: tagId,
            buildOnData: (collections) =>
                _CollectionsView(collections: collections),
          ),
        ),
      );
}

class _CollectionsView extends ConsumerWidget {
  const _CollectionsView({required this.collections});
  final Collections collections;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      title: collections.tag?.label ?? 'Collections',
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      actionsBuilder: [
        (
          BuildContext context,
          GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
        ) {
          return const PreviewSquareControlButton();
        }
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return CLMatrix3DAutoFit(
          itemCount: collections.entries.length,
          itemBuilder: itemBuilder,
          childSize: const Size(180, 300),
          layers: 2,
        );
      },
    );
  }

  Widget itemBuilder(BuildContext context, int index, int l) {
    final e = collections.entries[index];
    if (l > 1) {
      throw Exception('has only one layer!');
    }
    if (l == 0) {
      return GestureDetector(
        onTap: () => context.push('/items/by_collection_id/${e.id}'),
        child: LoadItems(
          collectionID: e.id!,
          hasBackground: false,
          buildOnData: (Items items, {required String docDir}) {
            final (hCount, vCount) = switch (items.entries.length) {
              1 => (1, 1),
              2 => (1, 2),
              <= 4 => (2, 2),
              < 6 => (2, 3),
              _ => (3, 3)
            };
            return CollectionBasePreview(
              item: e,
              mediaList: items.entries
                  .map(
                    (ItemInDB e) => e.toCLMedia(
                      pathPrefix: docDir,
                    ),
                  )
                  .toList(),
              mediaCountInPreview:
                  CLDimension(itemsInRow: hCount, itemsInColumn: vCount),
            );
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => context.push('/items/by_collection_id/${e.id}'),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Text(
            e.label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }
  }
}
