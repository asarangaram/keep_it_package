import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

final refreshReaderProvider = StateProvider<String>((ref) {
  ref.listenSelf((prev, curr) {
    log(
      'Trigger Refresh at $curr',
      name: 'refreshReaderProvider',
      time: DateTime.now(),
    );
  });

  return DateTime.now().toIso8601String();
});
