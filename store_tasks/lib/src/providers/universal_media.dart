import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_shared_media.dart';
import '../models/universal_media_source.dart';

class UniversalMediaNotifier extends StateNotifier<CLSharedMedia> {
  UniversalMediaNotifier(this.mediaTypes)
      : super(const CLSharedMedia(entries: ViewerEntities([])));
  UniversalMediaSource mediaTypes;

  set mediaGroup(CLSharedMedia sharedMedia) {
    state = CLSharedMedia(
      entries: sharedMedia.entries,
      collection: sharedMedia.collection,
      type: sharedMedia.type,
    );
  }

  CLSharedMedia get mediaGroup => state;

  void clear() => state = const CLSharedMedia(entries: ViewerEntities([]));

  Future<void> remove(ViewerEntities mediaList) async {
    final ids = mediaList.entities.map((e) => e.id);
    state = state.copyWith(
      entries: ViewerEntities(
          state.entries.entities.where((e) => !ids.contains(e.id)).toList()),
    );
  }
}

final StateNotifierProviderFamily<UniversalMediaNotifier, CLSharedMedia,
        UniversalMediaSource> universalMediaProvider =
    StateNotifierProvider.family<UniversalMediaNotifier, CLSharedMedia,
        UniversalMediaSource>((ref, mediaTypes) {
  return UniversalMediaNotifier(mediaTypes);
});
