import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/internal/fullscreen_layout.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../basic_page_service/widgets/page_manager.dart';
import 'widgets/cl_page_widget.dart';

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
              }
              return MediaViewService0(
                viewIdentifier: viewIdentifier,
                incoming: [if (entity != null) entity],
                itemBuilder: (context, entity) {
                  return Container();
                },
                whenEmpty: const WhenEmpty(),
                id: id,
              );
            },
          )
        else
          GetEntities(
            storeIdentity: storeIdentity,
            parentId: parentId,
            errorBuilder: errorBuilder,
            loadingBuilder: loadingWidget,
            builder: (entities) {
              if (entities.isEmpty) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  PageManager.of(context).pop();
                });
              }
              return MediaViewService0(
                viewIdentifier: viewIdentifier,
                incoming: entities,
                id: id,
                itemBuilder: (context, entity) {
                  return Container();
                },
                whenEmpty: const WhenEmpty(),
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
    required this.incoming,
    required this.itemBuilder,
    required this.whenEmpty,
    required this.id,
    this.filtersDisabled = false,
    super.key,
  });

  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;
  final int id;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;

  final bool filtersDisabled;
  final Widget whenEmpty;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MediaViewService0State();
}

class _MediaViewService0State extends ConsumerState<MediaViewService0> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WhenEmpty(
      onReset: () async {
        PageManager.of(context).pop(false);
        return true;
      },
    );
  }
}
