import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'video_player_state.dart';

final showControlsProvider = StateProvider<bool>((ref) {
  final state = ref.watch(videoPlayerStateProvider);
  return state.controllerAsync.when(
    data: (controller) => !controller.value.isPlaying,
    error: (_, __) => true,
    loading: () => true,
  );
});
