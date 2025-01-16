import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/when_empty.dart';

import 'package:store/store.dart';

import '../builders/grouper.dart';
import '../navigation/providers/active_collection.dart';
import 'cl_entity_grid_view.dart';
import 'folders_and_files/collection_as_folder.dart';
import 'folders_and_files/media_as_file.dart';

class EntityGrid extends ConsumerWidget {
  const EntityGrid({
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const numColumns = 3;
    final identifier = ref.watch(mainPageIdentifierProvider);
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: entities.isEmpty
          ? const WhenEmpty()
          : SelectionControl(
              incoming: entities,
              itemBuilder: (context, item) => switch (item.runtimeType) {
                Collection => CollectionAsFolder(
                    collection: item as Collection,
                    onTap: () {
                      ref
                          .read(
                            activeCollectionProvider.notifier,
                          )
                          .state = item.id;
                    },
                  ),
                CLMedia => MediaAsFile(
                    media: item as CLMedia,
                    parentIdentifier: identifier,
                    onTap: () async {
                      await PageManager.of(context, ref).openMedia(
                        item.id!,
                        collectionId: item.collectionId,
                        parentIdentifier: identifier,
                      );
                      return true;
                    },
                  ),
                _ => throw UnimplementedError(),
              },
              labelBuilder: (context, galleryMap, gallery) {
                return gallery.label == null
                    ? null
                    : CLText.large(
                        gallery.label!,
                        textAlign: TextAlign.start,
                      );
              },
              bannersBuilder: (context, galleryMap) {
                return [];
              },
              builder: ({
                required items,
                required itemBuilder,
                required labelBuilder,
                required bannersBuilder,
              }) {
                return GetFilterredMedia(
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  incoming: entities,
                  bannersBuilder: bannersBuilder,
                  builder: (
                    List<CLEntity> filterred, {
                    required List<Widget> Function(
                      BuildContext,
                      List<GalleryGroupCLEntity<CLEntity>>,
                    ) bannersBuilder,
                  }) {
                    return filterred.isEmpty
                        ? Center(
                            child: Column(
                              children: [
                                ...bannersBuilder(context, []),
                              ],
                            ),
                          )
                        : GetGroupedMedia(
                            errorBuilder: errorBuilder,
                            loadingBuilder: loadingBuilder,
                            incoming: filterred,
                            columns: numColumns,
                            builder: (galleryMap /* numColumns */) {
                              return CLEntityGridView(
                                identifier: identifier,
                                galleryMap: galleryMap,
                                bannersBuilder: bannersBuilder,
                                labelBuilder: labelBuilder,
                                itemBuilder: itemBuilder,
                                columns: numColumns,
                              );
                            },
                          );
                  },
                );
              },
            ),
    );
  }
}

class SelectionControl extends ConsumerWidget {
  const SelectionControl({
    required this.incoming,
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    super.key,
  });
  final List<CLEntity> incoming;
  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) bannersBuilder;
  final Widget Function({
    required List<CLEntity> items,
    required Widget Function(BuildContext, CLEntity) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    ) bannersBuilder,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identifier = ref.watch(mainPageIdentifierProvider);
    final selectionMode = ref.watch(selectModeProvider(identifier));
    if (!selectionMode) {
      return builder(
        items: incoming,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
        bannersBuilder: bannersBuilder,
      );
    }
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuControlNotifierProvider
            .overrideWith((ref) => MenuControlNotifier()),
      ],
      child: SelectionContol0(
        builder: builder,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
      ),
    );
  }
}

class SelectionContol0 extends ConsumerStatefulWidget {
  const SelectionContol0({
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    super.key,
  });

  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final Widget Function({
    required List<CLEntity> items,
    required Widget Function(BuildContext, CLEntity) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    ) bannersBuilder,
  }) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SelectionContol0State();
}

class _SelectionContol0State extends ConsumerState<SelectionContol0> {
  final GlobalKey parentKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    final identifier = ref.watch(mainPageIdentifierProvider);
    final selector = ref.watch(selectorProvider);

    final incoming = selector.entities;

    final selected = selector.count;

    final total = selector.entities.length;

    return Stack(
      key: parentKey,
      children: [
        widget.builder(
          items: incoming,
          itemBuilder: (context, item) {
            final itemWidget = widget.itemBuilder(
              context,
              item,
            );

            return SelectableItem(
              isSelected:
                  selector.isSelected([item]) != SelectionStatus.selectedNone,
              onTap: () {
                ref.read(selectorProvider.notifier).toggle([item]);
              },
              child: itemWidget,
            );
          },
          labelBuilder: (context, galleryMap, gallery) {
            final labelWidget =
                widget.labelBuilder(context, galleryMap, gallery);
            if (labelWidget == null) return const SizedBox.shrink();
            final candidates =
                galleryMap.getEntitiesByGroup(gallery.groupIdentifier).toList();
            return SelectableLabel(
              selectionStatus: selector.isSelected(
                candidates,
              ),
              onSelect: () {
                ref.read(selectorProvider.notifier).toggle(
                      candidates,
                    );
              },
              child: labelWidget,
            );
          },
          bannersBuilder: (context, galleryMap) {
            final allSelectedInVisible =
                selector.isSelected(galleryMap.getEntities.toList()) ==
                    SelectionStatus.selectedAll;
            return [
              SelectionCountView(
                selectionMsg: selected == 0
                    ? null
                    : ' $selected '
                        'of $total selected',
                buttonLabel:
                    allSelectedInVisible ? 'Select None' : 'Select All',
                onPressed: () {
                  if (allSelectedInVisible) {
                    ref
                        .read(selectorProvider.notifier)
                        .deselect(galleryMap.getEntities.toList());
                  } else {
                    ref
                        .read(selectorProvider.notifier)
                        .select(galleryMap.getEntities.toList());
                  }
                },
              ),
            ];
          },
        ),
        if (selector.items.isNotEmpty)
          GetStoreUpdater(
            builder: (theStore) {
              return ActionsDraggableMenu<CLEntity>(
                items: selector.items.toList(),
                tagPrefix: 'Selection',
                onDone: () {
                  ref.read(selectModeProvider(identifier).notifier).state =
                      false;
                },
                selectionActions: (context, entities) {
                  final items = entities.map((e) => e as CLMedia).toList();
                  return [
                    CLMenuItem(
                      title: 'Delete',
                      icon: clIcons.deleteItem,
                      onTap: () async {
                        final confirmed =
                            await ConfirmAction.deleteMediaMultiple(
                                  context,
                                  ref,
                                  media: items,
                                ) ??
                                false;
                        if (!confirmed) return confirmed;
                        if (context.mounted) {
                          return theStore.mediaUpdater.deleteMultiple(
                            {...items.map((e) => e.id!)},
                          );
                        }
                        return null;
                      },
                    ),
                    CLMenuItem(
                      title: 'Move',
                      icon: clIcons.imageMoveAll,
                      onTap: () => MediaWizardService.openWizard(
                        context,
                        ref,
                        CLSharedMedia(
                          entries: items,
                          type: UniversalMediaSource.move,
                        ),
                      ),
                    ),
                    CLMenuItem(
                      title: 'Share',
                      icon: clIcons.imageShareAll,
                      onTap: () => theStore.mediaUpdater.share(context, items),
                    ),
                    if (ColanPlatformSupport.isMobilePlatform)
                      CLMenuItem(
                        title: 'Pin',
                        icon: clIcons.pinAll,
                        onTap: () => theStore.mediaUpdater.pinToggleMultiple(
                          items.map((e) => e.id).toSet(),
                        ),
                      ),
                  ];
                },
                parentKey: parentKey,
              );
            },
          ),
      ],
    );
  }
}
