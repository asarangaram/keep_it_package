import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class MediaViewService extends StatelessWidget {
  const MediaViewService({
    required this.parentIdentifier,
    required this.entities,
    required this.currentIndex,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;
  final int currentIndex;
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        mediaViewerUIStateProvider.overrideWith((ref) {
          return MediaViewerUIStateNotifier(
            MediaViewerUIState(
              entities: entities,
              currentIndex: currentIndex,
            ),
          );
        }),
      ],
      child: CLMediaViewer(
        parentIdentifier: parentIdentifier,
      ),
    );
  }
}
