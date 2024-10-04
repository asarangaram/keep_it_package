import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupportOnlineNotifier extends AsyncNotifier<bool> {
  @override
  FutureOr<bool> build() {
    return true;
  }
}

final supportOnlineProvider =
    AsyncNotifierProvider<SupportOnlineNotifier, bool>(
  SupportOnlineNotifier.new,
);
