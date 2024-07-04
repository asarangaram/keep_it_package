// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UniversalMediaNotifier extends StateNotifier<CLSharedMedia> {
  UniversalMediaNotifier(this.mediaTypes)
      : super(const CLSharedMedia(entries: []));
  MediaSourceType mediaTypes;

  set mediaGroup(CLSharedMedia sharedMedia) {
    state = state.copyWith(
      entries: sharedMedia.entries,
      collection: sharedMedia.collection,
    );
  }

  CLSharedMedia get mediaGroup => state;

  void clear() => state = const CLSharedMedia(entries: []);

  Future<void> remove(List<CLMedia> mediaList) async {
    state = state.copyWith(
      entries: state.entries.where((e) => !mediaList.contains(e)).toList(),
    );
  }
}

final universalMediaProvider = StateNotifierProvider.family<
    UniversalMediaNotifier, CLSharedMedia, MediaSourceType>((ref, mediaTypes) {
  return UniversalMediaNotifier(mediaTypes);
});