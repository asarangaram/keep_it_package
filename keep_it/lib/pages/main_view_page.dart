import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../builders/get_main_view_entities.dart';
import '../builders/grouper.dart';
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
        /* appBar: AppBar(
          title: const MainViewTitle(),
          leading: const MainViewLeading(),
          automaticallyImplyLeading: false,
          actions: [
            const GroupAction(),
            const SelectControlIcon(),
            const SearchIcon(),
            const FileSelectAction(),
            if (ColanPlatformSupport.cameraSupported) const CameraAction(),
            const ExtraActions(),
          ],
        ), */
        body: OnSwipe(
          child: Stack(
            children: [
              Column(
                children: [
                  const SearchOptions(),
                  Expanded(
                    child: GetStore(
                      builder: (store) {
                        return RefreshIndicator(
                          onRefresh: /* isSelectionMode ? null : */ () async =>
                              store.reloadStore(),
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
              Positioned(
                left: 16,
                top: MediaQuery.of(context).viewPadding.top,
                child: SizedBox(
                  // width: MediaQuery.of(context).size.width * 0.5,
                  // height: 50,

                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        decoration: ShapeDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(220),
                          shape: const CircleBorder(), // Oval shape
                        ),
                        child: const MainViewLeading(),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        alignment: Alignment.centerLeft,
                        decoration: ShapeDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primaryContainer
                              .withAlpha(220),
                          shape: const StadiumBorder(), // Oval shape
                        ),
                        child: const MainViewTitle(),
                      ),
                    ],
                  ),
                ),
              ),
              /* SafeArea(
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: ColoredBox(
                        color: Theme.of(context)
                            .colorScheme
                            .primaryContainer
                            .withAlpha(200),
                        child: const MainViewTitle(),
                      ),
                    ),
                  ],
                ),
              ), */
            ],
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
