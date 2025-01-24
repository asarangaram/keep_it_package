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

import 'providers/app_init.dart';

class AppStartService extends StatelessWidget {
  const AppStartService({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: _AppLoader(
        appDescriptor: appDescriptor,
      ),
    );
  }
}

class _AppLoader extends ConsumerWidget {
  const _AppLoader({
    required this.appDescriptor,
  });
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(appDescriptor));
    return appInitAsync.when(
      data: (success) {
        final app = appDescriptor;
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: app.title,
          initialRoute: '/',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          darkTheme: ThemeData(
            primarySwatch: Colors.blue,
            brightness: Brightness.dark,
          ),
          themeMode: ThemeMode.light,
          onGenerateRoute: (settings) {
            final uri = Uri.parse(settings.name ?? '');

            final screen = app.screens
                .where((s) => s.name == uri.path.replaceFirst('/', ''))
                .firstOrNull;
            if (screen == null) {
              return MaterialPageRoute(
                builder: (context) => const Scaffold(
                  body: Center(
                    child: Text('404: Page not found'),
                  ),
                ),
              );
            }
            return MaterialPageRoute(
              builder: (context) => CLTheme(
                colors: const DefaultCLColors(),
                noteTheme: const DefaultNotesTheme(),
                child: IncomingMediaMonitor(
                  onMedia: app.incomingMediaViewBuilder,
                  child: screen.builder(context, uri.queryParameters),
                ),
              ),
            );
          },
        );
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
    );
  }
}

/* bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
} */
