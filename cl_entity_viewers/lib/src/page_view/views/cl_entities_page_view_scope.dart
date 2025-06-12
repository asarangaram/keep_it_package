import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../providers/ui_state.dart';

class CLEntitiesPageViewScope extends ConsumerWidget {
  const CLEntitiesPageViewScope({
    required this.siblings,
    required this.currentEntity,
    required this.child,
    super.key,
  });
  final List<ViewerEntity> siblings;
  final ViewerEntity currentEntity;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportedEntities = siblings
        .where(
          (e) => [
            CLMediaType.image,
            CLMediaType.video,
          ].contains(e.mediaType),
        )
        .toList();
    return ProviderScope(
      key: ValueKey(supportedEntities.hashCode),
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
      child: child,
    );
  }
}
