import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../incoming_media_service/models/cl_shared_media.dart';

class UniversalMediaNotifier extends StateNotifier<CLSharedMedia> {
  UniversalMediaNotifier(this.mediaTypes)
      : super(const CLSharedMedia(entries: []));
  UniversalMediaSource mediaTypes;

  set mediaGroup(CLSharedMedia sharedMedia) {
    state = CLSharedMedia(
      entries: sharedMedia.entries,
      collection: sharedMedia.collection,
      type: sharedMedia.type,
    );
  }

  CLSharedMedia get mediaGroup => state;

  void clear() => state = const CLSharedMedia(entries: []);

  Future<void> remove(List<CLMedia> mediaList) async {
    final ids = mediaList.map((e) => e.id);
    state = state.copyWith(
      entries: state.entries.where((e) => !ids.contains(e.id)).toList(),
    );
  }
}

final universalMediaProvider = StateNotifierProvider.family<
    UniversalMediaNotifier,
    CLSharedMedia,
    UniversalMediaSource>((ref, mediaTypes) {
  return UniversalMediaNotifier(mediaTypes);
});
