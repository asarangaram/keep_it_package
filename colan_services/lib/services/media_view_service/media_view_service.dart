import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../internal/fullscreen_layout.dart';
import '../basic_page_service/widgets/page_manager.dart';

import '../gallery_view_service/providers/active_collection.dart';
import '../gallery_view_service/widgets/basics/when_error.dart';

import 'media_view_service1.dart';

class MediaViewService extends ConsumerWidget {
  const MediaViewService({
    required this.id,
    required this.parentId,
    required this.parentIdentifier,
    required this.storeIdentity,
    super.key,
  });
  final String storeIdentity;
  final int? parentId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );
    final parentId = ref.watch(activeCollectionProvider)?.id;

    return AppTheme(
      child: FullscreenLayout(
        child: GetEntities(
          parentId: parentId,
          storeIdentity: storeIdentity,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetAvailableMediaByCollectionId',
          ),
          errorBuilder: errorBuilder,
          builder: (entities) => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
            ) =>
                FadeTransition(opacity: animation, child: child),
            child: KeepItMediaCorouselView(
              parentIdentifier: parentIdentifier,
              entities: entities,
              initialMediaIndex: id,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'KeepItMainGrid',
              ),
              errorBuilder: errorBuilder,
            ),
          ),
        ),
      ),
    );
  }
}

class KeepItMediaCorouselView extends ConsumerWidget {
  const KeepItMediaCorouselView({
    required this.parentIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    this.initialMediaIndex = 0,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;

  final int initialMediaIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );

    if (entities.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        PageManager.of(context).pop();
      });
    }
    //FIXME Filter
    return MediaViewService1.pageView(
      media: entities.map((e) => e).toList(),
      parentIdentifier: viewIdentifier.toString(),
      initialMediaIndex: entities.indexWhere((e) => e.id == initialMediaIndex),
      errorBuilder: errorBuilder,
      loadingBuilder: () => CLLoader.widget(
        debugMessage: 'MediaViewService.pageView',
      ),
    );

    /* return ViewModifierBuilder(
      viewIdentifier: ViewIdentifier(view: viewIdentifier, tabId: 'Media'),
      incoming: entities,
      bannersBuilder: (context, _) => [],
      builder: (
        List<ViewerEntityMixin> filterred, {
        required List<Widget> Function(
          BuildContext,
          List<ViewerEntityGroup<ViewerEntityMixin>>,
        ) bannersBuilder,
      }) {},
    ); */
  }
}
