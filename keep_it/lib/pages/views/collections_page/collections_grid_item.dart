import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:keep_it/pages/views/app_theme.dart';
import 'package:keep_it/pages/views/collections_page/collection_preview.dart';

import 'package:store/store.dart';

class CollectionsGridItem extends ConsumerWidget {
  const CollectionsGridItem({
    required this.quickMenuScopeKey,
    required this.size,
    required this.random,
    super.key,
    this.collection,
    this.onEditCollection,
    this.onDeleteCollection,
    this.onTapCollection,
  });
  final Collection? collection;
  final Random random;

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Size size;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onEditCollection;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onDeleteCollection;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onTapCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.read(collectionsProvider(null));

    return collection == null
        ? Container()
        : CLQuickMenuAnchor.longPress(
            parentKey: quickMenuScopeKey,
            menuBuilder: (
              context,
              boxconstraints, {
              required void Function() onDone,
            }) {
              return AppTheme(
                child: CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(
                    kMinInteractiveDimension * 1.5,
                    kMinInteractiveDimension * 1.5,
                  ),
                  children2D: [
                    [
                      CLMenuItem(
                        title: 'Edit',
                        icon: Icons.edit,
                        onTap: collectionsAsync.whenOrNull(
                          data: (Collections collections) => () async {
                            final res = await onEditCollection?.call(
                              context,
                              collection!,
                            );

                            if (res ?? false) {
                              onDone();
                            }
                            return res;
                          },
                        ),
                      ),
                      CLMenuItem(
                        title: 'Delete',
                        icon: Icons.delete,
                        onTap: () async {
                          final res = await onDeleteCollection?.call(
                            context,
                            collection!,
                          );

                          if (res ?? false) {
                            onDone();
                          }
                          return res;
                        },
                      ),
                    ]
                  ],
                ),
              );
            },
            onTap: (collection == null)
                ? null
                : () => onTapCollection?.call(context, collection!),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: CollectionPreview(random: random)),
                Text(
                  collection!.label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
  }
}
