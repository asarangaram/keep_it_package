import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class CapturedMediaNotifier extends StateNotifier<List<CLEntity>> {
  CapturedMediaNotifier() : super([]);

  void add(CLEntity media) {
    log('adding media with id ${media.id}');
    state = [...state, media];
  }

  void clear() {
    // Called after handing over the files to some other module.
    // We can ignore as deleting those files is the new owners responsibility
    log('clear the list');
    state = [];
  }

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Camera | Captured Media',
    );
  }
}

final capturedMediaProvider =
    StateNotifierProvider<CapturedMediaNotifier, List<CLEntity>>((ref) {
  return CapturedMediaNotifier();
});
