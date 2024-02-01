/// Run the application with ProviderScope
/// Implement a FutureProvider that invokes all initialization
/// routies as well trigger loading other providers
/// Watch this FutureProvider and once it gets results, draw the app
/// we can handle  errors if needed
/// replacing the FutureProvider by StreamProvider, we may also
/// show the progress
///
library;

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_descriptor.dart';

import 'app_view.dart';

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

class AppLoader extends ConsumerWidget {
  const AppLoader({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(appDescriptor));
    return appInitAsync.when(
      data: (success) {
        return AppView(appDescriptor: appDescriptor);
      },
      error: (err, _) {
        _infoLogger(err.toString());
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CLErrorView(errorMessage: err.toString()),
        );
      },
      loading: () => const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: CLLoadingView(),
      ),
    );
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
