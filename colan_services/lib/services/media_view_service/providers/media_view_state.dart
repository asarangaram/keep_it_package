import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/media_view_state.dart';

class MediaViewerStateNotifier extends StateNotifier<MediaViewerState> {
  MediaViewerStateNotifier(super.state) : super();

  set currIndex(int value) => state = state.copyWith(currentIndex: value);
  int get currIndex => state.currentIndex;
}

final mediaViewerStateProvider =
    StateNotifierProvider<MediaViewerStateNotifier, MediaViewerState>((ref) {
  return throw Exception('Override mising');
});
