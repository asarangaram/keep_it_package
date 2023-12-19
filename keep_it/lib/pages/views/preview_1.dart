
import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/media_entries_preview.dart';

import '../../db/db.dart';
import '../../models/collection.dart';
import '../../models/collections.dart';
import '../../providers/db_store.dart';
import '../../providers/selection.dart';
import '../../providers/theme.dart';

class SharedItemsViewInternal extends ConsumerStatefulWidget {
  const SharedItemsViewInternal({
    super.key,
    required this.media,
    required this.onDiscard,
    required this.dbManager,
  });

  final Map<String, SupportedMediaType> media;
  final Function() onDiscard;
  final DatabaseManager dbManager;

  @override
  ConsumerState<SharedItemsViewInternal> createState() =>
      _SharedItemsViewInternalState();
}

class _SharedItemsViewInternalState
    extends ConsumerState<SharedItemsViewInternal> {
  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);
    final collectionsAsync = ref.watch(collectionsProvider(null));
    return CLFullscreenBox(
      useSafeArea: true,
      backgroundColor: theme.colorTheme.backgroundColor,
      hasBorder: true,
      child: Column(
        children: [
          Expanded(
            flex: 9,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Flexible(
                      flex: 6,
                      child: PreviewOfMediaEntries(media: widget.media)),
                  Flexible(
                    flex: 4,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        collectionsAsync.when(
                            loading: () => const CLLoadingView(),
                            error: (err, _) => CLErrorView(
                                  errorMessage: err.toString(),
                                ),
                            data: (collections) =>
                                Text.rich(TextSpan(children: [
                                  TextSpan(
                                      text: "Tags: ",
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .copyWith(
                                              fontSize:
                                                  CLScaleType.small.fontSize,
                                              fontWeight: FontWeight.bold)),
                                  for (var collection in ref.watch(
                                      selectedItemsProvider(
                                          collections.collections)))
                                    TextSpan(
                                        text: "#${collection.label}, ",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge!
                                            .copyWith(
                                                fontSize:
                                                    CLScaleType.small.fontSize))
                                ]))),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CLText.large("Select Tags",
                              color: theme.colorTheme.textColor),
                        ),
                        Expanded(
                            child: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: SingleChildScrollView(
                            child: collectionsAsync.when(
                              loading: () => const CLLoadingView(),
                              error: (err, _) => CLErrorView(
                                errorMessage: err.toString(),
                              ),
                              data: (collections) => Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Wrap(
                                  spacing: 4.0,
                                  runSpacing: 4.0,
                                  alignment: WrapAlignment.start,
                                  runAlignment: WrapAlignment.start,
                                  children: [
                                    for (var c in collections.collections)
                                      CollectionChip(c)
                                  ],
                                ),
                              ),
                            ),
                          ),
                        )),
                      ],
                    ),
                  )
                ]),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Column(
                children: [
                  Flexible(
                    child: Center(
                      child: CLButtonText.large(
                        "Save",
                        color: theme.colorTheme.textColor,
                        disabledColor: theme.colorTheme.disabledColor,
                        onTap: () {},
                      ),
                    ),
                  ),
                  Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(), //incase of keyboard, implement this.
                        Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: CLButtonText.small(
                            "Cancel",
                            color: theme.colorTheme.textColor,
                            disabledColor: theme.colorTheme.disabledColor,
                            onTap: widget.onDiscard,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class CollectionsViewChips extends ConsumerWidget {
  const CollectionsViewChips({
    super.key,
    required this.collections,
  });
  final Collections collections;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 4.0,
      runSpacing: 4.0,
      alignment: WrapAlignment.spaceAround,
      runAlignment: WrapAlignment.start,
      children: [for (var c in collections.collections) CollectionChip(c)],
    );
  }
}

class CollectionChip extends ConsumerWidget {
  const CollectionChip(this.c, {super.key});
  final Collection c;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    SelectItem sc = ref.watch(selectItemProvider(c));

    return SizedBox(
      width: 80,
      child: CLButtonElevatedText.small(
        "#${sc.collection.label}",
        color: theme.colorTheme.textColor,
        disabledColor: theme.colorTheme.disabledColor,
        onTap: () {
          return ref.read(selectItemProvider(c).notifier).toggleSelection();
        },
        boxDecoration: BoxDecoration(
            color: sc.isSelected
                ? theme.colorTheme.selectedColor
                : theme.colorTheme.overlayBackgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(8))),
      ),
    );
  }
}
