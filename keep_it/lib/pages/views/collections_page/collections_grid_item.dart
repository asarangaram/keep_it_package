import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../constants.dart';

import '../app_theme.dart';
import 'collection_preview.dart';
import 'keepit_dialogs.dart';

class CollectionsGridItem extends ConsumerWidget {
  const CollectionsGridItem({
    super.key,
    required this.quickMenuScopeKey,
    this.collection,
    required this.size,
    required this.random,
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
            menuBuilder: (context, boxconstraints,
                {required Function() onDone}) {
              return AppTheme(
                child: CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(kMinInteractiveDimension * 1.5,
                      kMinInteractiveDimension * 1.5),
                  children2D: [
                    [
                      CLMenuItem('Edit', Icons.edit,
                          onTap: collectionsAsync.whenOrNull(
                              data: (Collections collections) => () =>
                                  KeepItDialogs.upsertCollection(context,
                                      onDone: onDone, collection: collection))),
                      CLMenuItem('Delete', Icons.delete, onTap: () {
                        onDone.call();
                        ref
                            .read(collectionsProvider(null).notifier)
                            .deleteCollection(collection!);
                      }),
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
    super.key,
    this.label,
    this.child,
    this.horizontalSpacing = 0,
    this.verticalSpacing = 0,
    required this.random,
  });

  final String? label;
  final Widget? child;
  final double horizontalSpacing;
  final double verticalSpacing;
  final Random random;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: (label != null) ? Constants.aspectRatio : 1.0,
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: horizontalSpacing, vertical: verticalSpacing),
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
                )
            ],
          ),
        ),
      ),
    );
  }
}
