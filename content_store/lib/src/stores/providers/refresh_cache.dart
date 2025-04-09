import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReloadNotifier extends StateNotifier<String> {
  ReloadNotifier() : super(DateTime.now().toIso8601String());

  void reload() {
    state = DateTime.now().toIso8601String();
  }
}

final reloadProvider = StateNotifierProvider<ReloadNotifier, String>((ref) {
  ref.listenSelf((prev, curr) {
    log(
      'Trigger Refresh at $curr',
      name: 'refreshReaderProvider',
      time: DateTime.now(),
    );
  });
  return ReloadNotifier();
});
