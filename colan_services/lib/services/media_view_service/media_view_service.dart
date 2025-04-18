import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/internal/fullscreen_layout.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../providers/show_controls.dart';
import '../../models/platform_support.dart';
import '../basic_page_service/basic_page_service.dart';
import '../basic_page_service/widgets/page_manager.dart';
import 'widgets/cl_page_widget.dart';
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
    return FullscreenLayout(
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
              return MediaViewService0(
                viewIdentifier: viewIdentifier,
                incoming: [entity],
                initialMediaIndex: id,
                errorBuilder: errorBuilder,
                loadingBuilder: loadingWidget,
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
              return MediaViewService0(
                viewIdentifier: viewIdentifier,
                incoming: entities,
                initialMediaIndex: entities.indexWhere((e) => e.id == id),
                errorBuilder: errorBuilder,
                loadingBuilder: loadingWidget,
              );
            },
          ),
      ][0],
    );
  }
}

class MediaViewService0 extends ConsumerStatefulWidget {
  const MediaViewService0({
    required this.viewIdentifier,
    required this.initialMediaIndex,
    required this.incoming,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.filtersDisabled = false,
    super.key,
  });

  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;
  final int initialMediaIndex;

  final bool filtersDisabled;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      MediaViewService0State();
}

class MediaViewService0State extends ConsumerState<MediaViewService0> {
  bool lockPage = false;

  late final PageController pageController;
  late int currIndex;

  @override
  void initState() {
    currIndex = widget.initialMediaIndex;
    pageController = PageController(initialPage: widget.initialMediaIndex);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (currIndex >= widget.incoming.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
      return BasicPageService.withNavBar(message: 'Media seems deleted');
    }

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    final showControl = ref.watch(showControlsProvider);
    if (!showControl.showStatusBar) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    } else {
      SystemChrome.setEnabledSystemUIMode(
        SystemUiMode.manual,
        overlays: SystemUiOverlay.values,
      );
    }
    return (widget.incoming.length == 1)
        ? itemBuilder(context, widget.incoming[0])
        : CLKeyListener(
            keyHandler: {
              if (!ColanPlatformSupport.isMobilePlatform)
                LogicalKeyboardKey.escape: () => PageManager.of(context).pop(),
              if (currIndex > 0)
                LogicalKeyboardKey.arrowLeft: () => pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
              else
                LogicalKeyboardKey.arrowLeft: () =>
                    pageController.animateToPage(
                      widget.incoming.length - 1,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
              if (currIndex < widget.incoming.length - 1)
                LogicalKeyboardKey.arrowRight: () => pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    )
              else
                LogicalKeyboardKey.arrowRight: () =>
                    pageController.animateToPage(
                      0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ),
            },
            child: Stack(
              children: [
                PageView.builder(
                  controller: pageController,
                  itemCount: widget.incoming.length,
                  physics:
                      lockPage ? const NeverScrollableScrollPhysics() : null,
                  onPageChanged: (index) {
                    setState(() {
                      currIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final media = widget.incoming[index];
                    return itemBuilder(context, media);
                  },
                ),
                if (currIndex > 0)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const CLIcon.large(LucideIcons.chevronLeft),
                    ),
                  ),
                if (currIndex < widget.incoming.length - 1)
                  Align(
                    alignment: Alignment.centerRight,
                    child: ShadButton.ghost(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const CLIcon.large(LucideIcons.chevronRight),
                    ),
                  ),
              ],
            ),
          );
  }

  void onLockPage({required bool lock}) {
    setState(() {
      lockPage = lock;
    });
  }

  Widget itemBuilder(
    BuildContext context,
    ViewerEntityMixin entity,
  ) {
    return MediaView(
      parentIdentifier: widget.viewIdentifier.parentID,
      media: entity as StoreEntity,
      isLocked: lockPage,
      autoStart: true,
      autoPlay: false,
      onLockPage: onLockPage,
      errorBuilder: widget.errorBuilder,
      loadingBuilder: widget.loadingBuilder,
    );
  }
}
