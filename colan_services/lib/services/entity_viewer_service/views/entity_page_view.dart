import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:cl_media_tools/cl_media_tools.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'bottom_bar_page_view.dart';
import 'top_bar_page_view.dart';

class EntityPageView extends StatelessWidget {
  const EntityPageView({
    required this.parentIdentifier,
    required this.siblings,
    required this.currentEntity,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> siblings;
  final StoreEntity currentEntity;
  @override
  Widget build(BuildContext context) {
    final supportedEntities = siblings
        .where(
          (e) => [
            CLMediaType.image,
            CLMediaType.video,
          ].contains(e.mediaType),
        )
        .toList();
    return ProviderScope(
      overrides: [
        mediaViewerUIStateProvider.overrideWith((ref) {
          return MediaViewerUIStateNotifier(
            MediaViewerUIState(
              entities: supportedEntities,
              currentIndex:
                  supportedEntities.indexWhere((e) => e.id == currentEntity.id),
            ),
          );
        }),
      ],
      child: CLMediaViewer(
        parentIdentifier: parentIdentifier,
        topMenu: const TopBarPageView(),
        bottomMenu: const BottomBarPageView(),
      ),
    );
  }
}
