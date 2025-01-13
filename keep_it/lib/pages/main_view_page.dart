import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_main_view_entities.dart';
import '../navigation/providers/active_collection.dart';
import '../widgets/action_icons.dart';

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
          child: Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    if (!ColanPlatformSupport.isMobilePlatform)
                      const SizedBox(
                        height: 8,
                      ),
                    const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              flex: 3,
                              child: MainViewTitle(),
                            ),
                            Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator.adaptive(),
                                  SearchIcon(),
                                  SizedBox(width: 8),
                                  ExtraActions(),
                                  SizedBox(width: 8),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SearchOptions(),
                      ],
                    ),
                    const SizedBox(height: 8),
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
              ),
              const SafeArea(
                child: Padding(
                  padding: EdgeInsets.all(8),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: ImportIcons(),
                  ),
                ),
              ),
            ],
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
