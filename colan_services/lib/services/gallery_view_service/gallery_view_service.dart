import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import 'models/entity_actions.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/entity_preview.dart';
import 'widgets/popover_menu.dart';
import 'widgets/stale_media_banner.dart';
import 'widgets/top_bar.dart';
import 'widgets/when_empty.dart';

class GalleryViewService extends ConsumerWidget {
  const GalleryViewService({
    required this.viewIdentifier,
    required this.storeIdentity,
    required this.parent,
    required this.children,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  final StoreEntity? parent;
  final List<StoreEntity> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        selectModeProvider.overrideWith((ref) => SelectModeNotifier()),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            parent?.data.label!.capitalizeFirstLetter() ?? 'Keep It',
            style: ShadTheme.of(context).textTheme.h1,
          ),
          actions: [
            if (!ColanPlatformSupport.isMobilePlatform)
              ShadButton.ghost(
                onPressed: ref.read(reloadProvider.notifier).reload,
                child: const Icon(LucideIcons.refreshCcw),
              ),
            if (children.isNotEmpty)
              PopOverMenu(viewIdentifier: viewIdentifier)
            else
              ShadButton.ghost(
                onPressed: () => PageManager.of(context).openSettings(),
                child: const Icon(LucideIcons.settings),
              ),
          ],
        ),
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: GalleryViewService0(
              parentIdentifier: viewIdentifier.parentID,
              storeIdentity: storeIdentity,
              parent: parent,
              entities: children,
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryViewService0 extends ConsumerWidget {
  const GalleryViewService0({
    required this.storeIdentity,
    required this.parentIdentifier,
    required this.parent,
    required this.entities,
    super.key,
  });

  final String storeIdentity;
  final String parentIdentifier;
  final StoreEntity? parent;
  final List<StoreEntity> entities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = parent?.id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: (parent?.id).toString(),
    );

    if (entities.isEmpty && parent?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      });
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: Column(
        children: [
          KeepItTopBar(
            viewIdentifier: viewIdentifier,
            entities: entities,
            title: parent?.label!.capitalizeFirstLetter() ?? 'Keep It',
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: /* isSelectionMode ? null : */
                  () async => ref.read(reloadProvider.notifier).reload(),
              child: Column(
                children: [
                  if (parentId == null)
                    StaleMediaBanner(
                      storeIdentity: storeIdentity,
                    ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: CLGalleryGridView(
                        viewIdentifier: viewIdentifier,
                        incoming: entities,
                        filtersDisabled: false,
                        onSelectionChanged: null,
                        contextMenuBuilder: (context, entities) =>
                            EntityActions.entities(
                          context,
                          ref,
                          entities,
                        ),
                        itemBuilder: (context, item, entities) => EntityPreview(
                          viewIdentifier: viewIdentifier,
                          item: item,
                          entities: entities,
                          parentId: parentId,
                        ),
                        whenEmpty: const WhenEmpty(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            KeepItBottomBar(
              storeIdentity: storeIdentity,
              id: parentId,
            ),
        ],
      ),
    );
  }
}

class OnSwipe extends ConsumerWidget {
  const OnSwipe({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (PageManager.of(context).canPop()) {
            PageManager.of(context).pop();
          }
        }
      },
      child: child,
    );
  }
}
