import 'package:app_loader/app_loader.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_main_view_entities.dart';
import '../navigation/providers/active_collection.dart';

import '../widgets/actions/bottom_bar.dart';
import '../widgets/actions/top_bar.dart';
import '../widgets/entity_grid.dart';
import '../widgets/utils/error_view.dart';
import '../widgets/utils/loading_view.dart';

class MainViewPage extends ConsumerWidget {
  const MainViewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) =>
        ErrorView(error: e, stackTrace: st);
    const Widget loadingWidget = LoadingView();
    return AppTheme(
      child: Scaffold(
        body: OnSwipe(
          child: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    const KeepItTopBar(),
                    Expanded(
                      child: GetStore(
                        builder: (store) {
                          return RefreshIndicator(
                            onRefresh: /* isSelectionMode ? null : */
                                () async => store.reloadStore(),
                            child: GetMainViewEntities(
                              loadingBuilder: () => loadingWidget,
                              errorBuilder: errorBuilder,
                              builder: (entities) => EntityGrid(
                                entities: entities,
                                loadingBuilder: () => loadingWidget,
                                errorBuilder: errorBuilder,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                if (MediaQuery.of(context).viewInsets.bottom == 0)
                  const KeepItBottomBar(),
              ],
            ),
          ),
        ),
        // Bottom Area with Three FABs
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
