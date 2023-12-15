// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../constants.dart';
import '../../models/collection.dart';
import '../../models/collections.dart';
import '../../models/theme.dart';

import '../../providers/theme.dart';
import 'app_theme.dart';
import 'collections_page/add_collection.dart';
import 'collections_page/add_collection_form.dart';
import 'collections_page/main_header.dart';

class CollectionsView2 extends ConsumerStatefulWidget {
  const CollectionsView2({super.key, required this.collections});

  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsView2State();
}

class _CollectionsView2State extends ConsumerState<CollectionsView2> {
  final GlobalKey quickMenuScopeKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(themeProvider);

    return CLFullscreenBox(
      useSafeArea: true,
      backgroundColor: theme.colorTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: CLQuickMenuScope(
          key: quickMenuScopeKey,
          child: AppTheme(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        MainHeader(quickMenuScopeKey: quickMenuScopeKey),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CLText.large(
                            "Your Collections",
                            color: theme.colorTheme.textColor,
                          ),
                        ),
                        Flexible(
                          child: (widget.collections.isEmpty)
                              ? Center(
                                  child: CLText.small(
                                    "No collections found",
                                    color: theme.colorTheme.textColor,
                                  ),
                                )
                              : Expanded(
                                  child: LayoutBuilder(
                                    builder: buildGrid,
                                  ),
                                ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                      ]),
                ),
                AddNewCollection(quickMenuScopeKey: quickMenuScopeKey)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildGrid(context, constraints) {
    return PaginatedGrid(
      collections: widget.collections.collections,
      constraints: constraints,
    );
  }
}

class PaginatedGrid extends ConsumerWidget {
  const PaginatedGrid({
    super.key,
    required this.collections,
    required this.constraints,
  });
  final List<Collection> collections;
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const childSize = Size(100, 100);
    PaginatedCollection paginatedCollection = PaginatedCollection(
        items: collections,
        itemSize: childSize,
        pageSize: Size(
          constraints.maxWidth,
          constraints.maxHeight,
        ));
    return CLPageView(
      pageBuilder: (BuildContext context, int pageNum) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (var r = 0; r < paginatedCollection.itemsInColumn; r++)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  for (var c = 0; c < paginatedCollection.itemsInRow; c++)
                    Container(
                      width: childSize.width,
                      height: childSize.height,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(border: Border.all()),
                      child: Center(
                        child: Text(
                            paginatedCollection.getItem(pageNum, r, c)?.label ??
                                "Empty"),
                      ),
                    )
                ],
              )
          ],
        );
      },
      pageMax: paginatedCollection.pageMax,
    );
  }
}

/* class CollectionGrid extends ConsumerWidget {
  const CollectionGrid({
    super.key,
    required this.collectionsPage,
    required this.quickMenuScopeKey,
  });
  final List<Collection> collectionsPage;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    if (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 500) {
      return Align(
        alignment: Alignment.topCenter,
        child: CLText.large(
          "Expand the window to view",
          color: theme.colorTheme.errorColor,
        ),
      );
    }
    return Center(
      child: SizedBox(
        width: double.maxFinite,
        child: Wrap(
          //direction: Axis.horizontal,
          spacing: 2.0,
          runSpacing: 2.0,
          alignment: WrapAlignment.spaceEvenly,
          //runAlignment: WrapAlignment.spaceAround,
          /* 
          GridView.countcrossAxisCount: 4,
          padding: EdgeInsets.zero,
          crossAxisSpacing: 2,
          mainAxisSpacing: 2,
          shrinkWrap: true,
          childAspectRatio: Constants.aspectRatio,
          physics: const NeverScrollableScrollPhysics(), */
          children: collectionsPage
              .map((Collection e) =>
                  CollectionView(quickMenuScopeKey: quickMenuScopeKey))
              .toList(),
        ),
      ),
    );
  }
}  */
/* 
class CollectionView extends ConsumerWidget {
  const CollectionView({
    super.key,
    required this.quickMenuScopeKey,
  });

  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.read(collectionsProvider(null));
    final theme = ref.watch(themeProvider);
    return SizedBox(
      width: 200,
      child: CLQuickMenuAnchor.longPress(
        parentKey: quickMenuScopeKey,
        color: theme.colorTheme.textColor,
        disabledColor: theme.colorTheme.disabledColor,
        menuBuilder: (context, boxconstraints, {required Function() onDone}) {
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
                                  context,
                                  collections,
                                  e,
                                  theme,
                                ),
                              );
                            })),
                CLQuickMenuItem('Delete', Icons.delete, onTap: () {
                  onDone.call();
                  ref
                      .read(collectionsProvider(null).notifier)
                      .deleteCollection(e);
                }),
              ],
              foregroundColor: theme.colorTheme.textColor,
              backgroundColor: theme.colorTheme.overlayBackgroundColor,
              disabledColor: theme.colorTheme.disabledColor,
            ),
          );
        },
        child: CLRoundIconLabeled(
          label: e.label,
        ),
      ),
    );
  }
} */

buildEditor(BuildContext context, Collections collections,
    Collection collection, KeepItTheme theme,
    {Function()? onDone}) {
  return Dialog(
    backgroundColor: theme.colorTheme.backgroundColor,
    insetPadding: const EdgeInsets.all(8.0),
    child: UpsertCollectionForm(
      collections: collections,
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
  });

  final String? label;
  final Widget? child;
  final double horizontalSpacing;
  final double verticalSpacing;

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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.0),
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          color: Colors.primaries[
                              Random().nextInt(Colors.primaries.length)],
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: child),
                  ),
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
