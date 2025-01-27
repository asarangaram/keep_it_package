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
import 'package:shadcn_ui/shadcn_ui.dart';

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
    final app = appDescriptor;
    return ShadApp(
      debugShowCheckedModeBanner: false,
      title: app.title,
      initialRoute: '/',
      theme: ShadThemeData(
        brightness: Brightness.light,
        colorScheme: const ShadZincColorScheme.light(),
        // Example with google fonts
        // textTheme: ShadTextTheme.fromGoogleFont(GoogleFonts.poppins),

        // Example of custom font family
        // textTheme: ShadTextTheme(family: 'UbuntuMono'),

        // Example to disable the secondary border
        // disableSecondaryBorder: true,
      ),
      darkTheme: ShadThemeData(
        brightness: Brightness.dark,
        colorScheme: const ShadZincColorScheme.dark(),
        // Example of custom font family
        // textTheme: ShadTextTheme(family: 'UbuntuMono'),
      ),
      themeMode: ThemeMode.light,
      onGenerateRoute: (settings) {
        final uri = Uri.parse(settings.name ?? '');

        return MaterialPageRoute(
          builder: (context) => CLTheme(
            colors: const DefaultCLColors(),
            noteTheme: const DefaultNotesTheme(),
            child: BuildScreen(app: app, uri: uri),
          ),
        );
      },
    );
  }
}

class BuildScreen extends ConsumerWidget {
  const BuildScreen({
    required this.app,
    required this.uri,
    super.key,
  });

  final AppDescriptor app;

  final Uri uri;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appInitAsync = ref.watch(appInitProvider(app));
    return appInitAsync.when(
      data: (success) {
        final screen = app.screens
            .where((s) => s.name == uri.path.replaceFirst('/', ''))
            .firstOrNull;
        if (screen == null) {
          return const Scaffold(
            body: Center(
              child: Text('404: Page not found'),
            ),
          );
        }
        return IncomingMediaMonitor(
          onMedia: app.incomingMediaViewBuilder,
          child: screen.builder(context, uri.queryParameters),
        );
      },
      error: (err, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CLErrorView(errorMessage: err.toString()),
        );
      },
      loading: () {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          home: CLLoader.widget(
            debugMessage: 'appInitAsync',
          ),
        );
      },
    );
  }
}

/* bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
} */
