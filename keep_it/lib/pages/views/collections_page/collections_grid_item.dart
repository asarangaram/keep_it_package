import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:keep_it/pages/views/app_theme.dart';
import 'package:keep_it/pages/views/collections_page/collection_preview.dart';
import 'package:keep_it/pages/views/collections_page/keepit_dialogs.dart';
import 'package:store/store.dart';

class CollectionsGridItem extends ConsumerWidget {
  const CollectionsGridItem({
    required this.quickMenuScopeKey,
    required this.size,
    required this.random,
    super.key,
    this.collection,
  });
  final Collection? collection;
  final Random random;

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Size size;

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
                        'Edit',
                        Icons.edit,
                        onTap: collectionsAsync.whenOrNull(
                          data: (Collections collections) => () async {
                            final res = await KeepItDialogs.upsertCollection(
                              context,
                              collection: collection,
                            );
                            if (res ?? false) {
                              onDone();
                            }
                          },
                        ),
                      ),
                      CLMenuItem(
                        'Delete',
                        Icons.delete,
                        onTap: () {
                          onDone.call();
                          ref
                              .read(collectionsProvider(null).notifier)
                              .deleteCollection(collection!);
                        },
                      ),
                    ]
                  ],
                ),
              );
            },
            child: CLRoundIconLabeled(label: collection!.label, random: random),
          );
  }
}

class CLRoundIconLabeled extends StatelessWidget {
  const CLRoundIconLabeled({
    required this.random,
    super.key,
    this.label,
    this.child,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
  });

  final String? label;
  final Widget? child;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Random random;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: (label != null) ? 1.4 : 1.0,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: horizontalSpacing,
          vertical: verticalSpacing,
        ),
        child: SizedBox.expand(
          child: Column(
            children: [
              CollectionPreview(random: random, child: child),
              if (label != null)
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Text(
                      label!,
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
