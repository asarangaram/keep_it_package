import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'builders/available_media.dart';

import 'providers/active_collection.dart';

import 'widgets/keep_it_main_grid.dart';
import 'widgets/when_error.dart';

class GalleryViewService extends StatelessWidget {
  const GalleryViewService({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );
    const parentIdentifier = 'KeepItMainGrid';

    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: GetStoreUpdater(
              errorBuilder: errorBuilder,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'GetStore',
              ),
              builder: (theStore) {
                return GetAvailableMediaByActiveCollectionId(
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'GetAvailableMediaByCollectionId',
                  ),
                  errorBuilder: errorBuilder,
                  builder: (clmedias) => RefreshIndicator(
                    onRefresh: /* isSelectionMode ? null : */
                        () async => theStore.store.reloadStore(),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      transitionBuilder: (
                        Widget child,
                        Animation<double> animation,
                      ) =>
                          FadeTransition(opacity: animation, child: child),
                      child: KeepItMainGrid(
                        parentIdentifier: parentIdentifier,
                        clmedias: clmedias,
                        theStore: theStore,
                        loadingBuilder: () => CLLoader.widget(
                          debugMessage: 'KeepItMainGrid',
                        ),
                        errorBuilder: errorBuilder,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class OnSwipe extends ConsumerWidget {
  const OnSwipe({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        if (details.primaryVelocity == null) return;
        // pop on Swipe
        if (details.primaryVelocity! > 0) {
          if (collectionId != null) {
            ref.read(activeCollectionProvider.notifier).state = null;
          }
        }
      },
      child: child,
    );
  }
}
