import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../constants.dart';

import '../app_theme.dart';
import 'add_collection_form.dart';

class CollectionView extends ConsumerWidget {
  const CollectionView({
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
                child: CLQuickMenuGrid(
                  menuItems: [
                    CLQuickMenuItem('Edit', Icons.edit,
                        onTap: collectionsAsync.whenOrNull(
                            data: (Collections collections) => () {
                                  onDone.call();
                                  showDialog<void>(
                                    context: context,
                                    builder: (context) => buildEditor(
                                        context, collections, collection!),
                                  );
                                })),
                    CLQuickMenuItem('Delete', Icons.delete, onTap: () {
                      onDone.call();
                      ref
                          .read(collectionsProvider(null).notifier)
                          .deleteCollection(collection!);
                    }),
                  ],
                ),
              );
            },
            child: CLRoundIconLabeled(label: collection!.label, random: random),
          );
  }
}

buildEditor(
    BuildContext context, Collections collections, Collection collection,
    {Function()? onDone}) {
  return Dialog(
    insetPadding: const EdgeInsets.all(8.0),
    child: UpsertCollectionForm(
      collection: collection,
      onDone: onDone,
    ),
  );
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
              AspectRatio(
                aspectRatio: 1.0,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        color: Colors
                            .primaries[random.nextInt(Colors.primaries.length)],
                        borderRadius:
                            const BorderRadius.all(Radius.circular(12)),
                      ),
                      child: child),
                ),
              ),
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
