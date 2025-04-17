import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../builders/on_init_done.dart';
import '../../builders/state_provider_scope.dart';
import '../../models/app_descriptor.dart';
import '../incoming_media_service/incoming_media_monitor.dart';

class AppStartService extends StatelessWidget {
  const AppStartService({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context) {
    final app = appDescriptor;
    return StateProviderScope(
      child: ShadApp(
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

          return PageRouteBuilder(
            transitionsBuilder: app.transitionBuilder,
            pageBuilder: (context, animation, secondaryAnimation) => CLTheme(
              colors: const DefaultCLColors(),
              noteTheme: const DefaultNotesTheme(),
              child: OnInitDone(
                app: app,
                uri: uri,
                builder: () {
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
              ),
            ),
          );
        },
      ),
    );
  }
}
