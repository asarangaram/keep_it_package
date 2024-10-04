import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportOnlineNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() {
    return false;
  }
}

final supportOnlineProvider =
    AsyncNotifierProvider<SupportOnlineNotifier, bool>(
  SupportOnlineNotifier.new,
);
