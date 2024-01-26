import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../controls/is_preview_square.dart';
import '../providers/state_providers.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';

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
        return CLMatrix2D(
          itemCount: collections.entries.length,
          itemBuilder: itemBuilder,
          columns: 2,
          layers: 2,
          /* decoration: BoxDecoration(
            color: Theme.of(context)
                .colorScheme
                .tertiaryContainer
                .reduceBrightness(0.05),
            borderRadius: BorderRadius.circular(2),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onTertiaryContainer,
              ),
            ],
          ),
          borderSide: const BorderSide(), */
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

            return CLMediaGridViewFixedWrap(
              mediaList: items.entries
                  .map(
                    (ItemInDB e) => e.toCLMedia(
                      pathPrefix: docDir,
                    ),
                  )
                  .toList(),
              hCount: hCount,
              vCount: vCount,
            );
          },
        ),
      );
    } else {
      return GestureDetector(
        onTap: () => context.push('/items/by_collection_id/${e.id}'),
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8,
            right: 8,
            top: 8,
            bottom: 8,
          ),
          child: Align(
            alignment: Alignment.topCenter,
            child: Text(
              (e.description.isEmpty) ? 'Empty' : e.description,
              textAlign: TextAlign.start,
            ),
          ),
        ),
      );
    }
  }
}

//
/*

*/
class CLMediaGridViewFixedWrap extends ConsumerWidget {
  const CLMediaGridViewFixedWrap({
    required this.mediaList,
    required this.hCount,
    super.key,
    this.vCount,
  });
  final List<CLMedia> mediaList;
  final int hCount;
  final int? vCount;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPreviewSquare = ref.watch(isPreviewSquareProvider);
    return CLMediaGridViewFixed(
      mediaList: mediaList,
      hCount: hCount,
      vCount: vCount,
      keepAspectRatio: !isPreviewSquare,
    );
  }
}
