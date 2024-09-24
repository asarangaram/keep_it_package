import 'dart:developer' as dev;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'active_server.dart';

void _log(
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
    name: 'Online Service: Work Offline:',
  );
}

final workingOfflineProvider = StateProvider<bool>((ref) {
  ref.listenSelf((prev, curr) {
    if (prev == null || prev == curr) return;
    final isWorkingOnlineEnabled = curr;
    _log(isWorkingOnlineEnabled ? 'Enabled' : 'Disabled');

    if (isWorkingOnlineEnabled) {
      _log('Request abortDownloads');
      ref.read(activeServerProvider.notifier).abortDownloads();
    } else {
      _log('Request Sync');
      ref.read(activeServerProvider.notifier).sync();
    }
  });
  return false;
});
