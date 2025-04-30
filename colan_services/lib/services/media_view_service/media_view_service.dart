/* import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:colan_services/internal/fullscreen_layout.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../internal/cl_page_widget.dart';
import '../basic_page_service/widgets/page_manager.dart';
import 'models/media_view_state.dart';
import 'providers/media_view_state.dart';
import 'widgets/media_view.dart';

class MediaViewService extends CLPageWidget {
  const MediaViewService({
    required this.parentIdentifier,
    required this.storeIdentity,
    required this.id,
    super.key,
    this.parentId,
  });
  final String parentIdentifier;
  final String storeIdentity;
  final int id;
  final int? parentId;

  @override
  String get widgetLabel => 'MediaViewService';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: '$parentId $id',
    );

    return AppTheme(
      child: FullscreenLayout(
        child: [
          if (parentId == 0)
            GetEntity(
              storeIdentity: storeIdentity,
              id: id,
              errorBuilder: errorBuilder,
              loadingBuilder: loadingWidget,
              builder: (entity) {
                if (entity == null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    PageManager.of(context).pop();
                  });
                  return const WhenEmpty();
                }
                return ProviderScope(
                  overrides: [
                    mediaViewerStateProvider.overrideWith(
                      (ref) => MediaViewerStateNotifier(
                        MediaViewerState(entities: [entity]),
                      ),
                    ),
                  ],
                  child: MediaPageView(
                    viewIdentifier: viewIdentifier,
                  ),
                );
              },
            )
          else
            GetEntities(
              storeIdentity: storeIdentity,
              parentId: parentId,
              errorBuilder: errorBuilder,
              loadingBuilder: loadingWidget,
              isCollection: false,
              builder: (entities) {
                if (entities.isEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    PageManager.of(context).pop();
                  });
                  return WhenEmpty(
                    onReset: () async {
                      PageManager.of(context).pop(false);
                      return true;
                    },
                  );
                }
                return ProviderScope(
                  overrides: [
                    mediaViewerStateProvider.overrideWith(
                      (ref) => MediaViewerStateNotifier(
                        MediaViewerState(
                          entities: entities,
                          currentIndex: entities.indexWhere((e) => e.id == id),
                        ),
                      ),
                    ),
                  ],
                  child: MediaPageView(
                    viewIdentifier: viewIdentifier,
                  ),
                );
              },
            ),
        ][0],
      ),
    );
  }
}

class MediaPageView extends ConsumerStatefulWidget {
  const MediaPageView({
    required this.viewIdentifier,
    super.key,
  });

  final ViewIdentifier viewIdentifier;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => MediaPageViewState();
}

class MediaPageViewState extends ConsumerState<MediaPageView> {
  late final PageController pageController;

  @override
  void initState() {
    pageController = PageController(
      initialPage: ref.read(mediaViewerStateProvider).currentIndex,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mediaViewerState = ref.watch(mediaViewerStateProvider);
    return GetVideoPlayerControls(
      builder: (videoControls) {
        return PageView.builder(
          controller: pageController,
          itemCount: mediaViewerState.entities.length,
          physics: mediaViewerState.lockScreen
              ? const NeverScrollableScrollPhysics()
              : null,
          onPageChanged: (index) {
            ref.read(mediaViewerStateProvider.notifier).currIndex = index;
          },
          itemBuilder: (context, index) {
            return MediaView(
              parentIdentifier: widget.viewIdentifier.parentID,
              media: mediaViewerState.entities[index] as StoreEntity,
              isLocked: mediaViewerState.lockScreen, //FIXME
              onLockPage: ({required bool lock}) {
                ref.read(mediaViewerStateProvider.notifier).lockScreen = lock;
              },
              autoStart: index == mediaViewerState.currentIndex,
              autoPlay: false,
              errorBuilder: (_, __) => throw UnimplementedError(''),
              loadingBuilder: GreyShimmer.show,
              videoControls: videoControls,
              pageController: pageController,
            );
          },
        );
      },
    );
  }
}
 */
