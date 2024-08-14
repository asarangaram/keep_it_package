import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CapturedMediaNotifier extends StateNotifier<List<CLMedia>> {
  CapturedMediaNotifier() : super([]);

  void add(CLMedia media) {
    state = [...state, media];
  }

  void clear() {
    // Called after handing over the files to some other module.
    // We can ignore as deleting those files is the new owners responsibility
    state = [];
  }
}

final capturedMediaProvider =
    StateNotifierProvider<CapturedMediaNotifier, List<CLMedia>>((ref) {
  return CapturedMediaNotifier();
});
