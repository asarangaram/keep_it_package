import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_descriptor.dart';

final appInitProvider =
    FutureProvider.family<void, AppDescriptor>((ref, appDescriptor) async {
  try {
    final result = await appDescriptor.appInitializer(ref);
    if (!result) {
      throw Exception('Initialization Failed');
    }
  } on Exception {
    // Handle or rethrow
    rethrow;
  }
  return;
});
