import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/camera_state.dart';

class CameraStateNotifier extends StateNotifier<CameraState> {
  CameraStateNotifier(super.cameraState);
}

final cameraStateProvider =
    StateNotifierProvider<CameraStateNotifier, CameraState>((ref) {
  throw Exception('Use within CameraView widget');
});
