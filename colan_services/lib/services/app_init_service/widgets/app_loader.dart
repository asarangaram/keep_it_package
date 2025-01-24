/// Run the application with ProviderScope
/// Implement a FutureProvider that invokes all initialization
/// routies as well trigger loading other providers
/// Watch this FutureProvider and once it gets results, draw the app
/// we can handle  errors if needed
/// replacing the FutureProvider by StreamProvider, we may also
/// show the progress
///
library;

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_init.dart';
import 'app_view.dart';

class AppStartService extends StatelessWidget {
  const AppStartService({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: AppStartService0(
        appDescriptor: appDescriptor,
      ),
    );
  }
}

class AppStartService0 extends ConsumerWidget {
  const AppStartService0({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(appDescriptor));
    return CLTheme(
      colors: const DefaultCLColors(),
      noteTheme: const DefaultNotesTheme(),
      child: appInitAsync.when(
        data: (success) {
          return AppView(appDescriptor: appDescriptor);
        },
        error: (err, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: CLErrorView(errorMessage: err.toString()),
          );
        },
        loading: () => MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CLLoader.widget(
            debugMessage: 'appInitAsync',
          ),
        ),
      ),
    );
  }
}

/* bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
} */
