import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_descriptor.dart';

final appInitProvider =
    FutureProvider.family<void, AppDescriptor>((ref, appDescriptor) async {
  try {
    final result = await appDescriptor.appInitializer(ref);
    if (!result) {
      exceptionLogger('Initialization Failed', 'appInitializer return null');
    }
  } catch (e) {
    // Handle or rethrow
    exceptionLogger('Initialization Failed', e.toString());
  }
  return;
});
