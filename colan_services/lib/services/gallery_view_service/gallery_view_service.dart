import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/entity_actions.dart';
import 'providers/active_collection.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/entity_preview.dart';
import 'widgets/stale_media_banner.dart';
import 'widgets/top_bar.dart';
import 'widgets/when_empty.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends StatelessWidget {
  const GalleryViewService({
    required this.parentIdentifier,
    required this.storeIdentity,
    super.key,
  });
  final String parentIdentifier;
  final String storeIdentity;

  @override
  Widget build(BuildContext context) {
    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: GalleryViewService0(
              storeIdentity: storeIdentity,
              parentIdentifier: parentIdentifier,
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
    super.key,
  });

  final String storeIdentity;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider)?.id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );

    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );
    return GetEntities(
      parentId: parentId,
      storeIdentity: storeIdentity,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'GalleryViewService',
      ),
      errorBuilder: errorBuilder,
      builder: (entities) {
        if (entities.isEmpty && parentId != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(activeCollectionProvider.notifier).state = null;
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
              KeepItTopBar(viewIdentifier: viewIdentifier, entities: entities),
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
                                EntityActions.entitiesContextMenuBuilder(
                              context,
                              ref,
                              entities,
                            ),
                            itemBuilder: (context, item) => EntityPreview(
                              viewIdentifier: viewIdentifier,
                              item: item,
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
                ),
            ],
          ),
        );
      },
    );
  }
}

class OnSwipe extends ConsumerWidget {
  const OnSwipe({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (parentId != null) {
            ref.read(activeCollectionProvider.notifier).state = null;
          }
        }
      },
      child: child,
    );
  }
}
