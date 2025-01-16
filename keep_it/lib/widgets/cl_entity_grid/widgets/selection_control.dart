import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../../../navigation/providers/active_collection.dart';

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
            return [
              SelectionBanner(galleryMap: galleryMap),
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
                          onGetPath: (media) {
                            throw UnimplementedError(
                              'onGetPath not yet implemented',
                            );
                          },
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

class SelectionBanner extends ConsumerWidget {
  const SelectionBanner({super.key, this.galleryMap = const []});
  final List<GalleryGroupCLEntity> galleryMap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);

    final allCount = selector.entities.length;
    final selectedInAllCount = selector.count;
    final currentItems = galleryMap.getEntities.toList();

    final selectionStatusOnVisible =
        selector.isSelected(currentItems) == SelectionStatus.selectedAll;
    final visibleCount = currentItems.length;
    final selectedInVisible = selector.selectedItems(currentItems);
    final selectedInVisibleCount = selectedInVisible.length;

    return SelectionCountView(
      buttonLabel: selectionStatusOnVisible ? 'Select None' : 'Select All',
      onPressed: () {
        if (selectionStatusOnVisible) {
          ref
              .read(selectorProvider.notifier)
              .deselect(galleryMap.getEntities.toList());
        } else {
          ref
              .read(selectorProvider.notifier)
              .select(galleryMap.getEntities.toList());
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedInAllCount > 0) ...[
            if (selectedInVisibleCount > 0)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '$selectedInVisibleCount of $visibleCount selected.',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref
                              .read(selectorProvider.notifier)
                              .deselect(selectedInVisible);
                        },
                    ),
                  ],
                ),
              ),
            if (visibleCount < allCount)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total: $selectedInAllCount of $allCount selected',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref.read(selectorProvider.notifier).clear();
                        },
                    ),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}
