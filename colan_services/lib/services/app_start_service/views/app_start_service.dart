import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../builders/on_init_done.dart';

import '../../../models/app_descriptor.dart';
import '../../incoming_media_service/incoming_media_monitor.dart';
import '../notifiers/app_preferences.dart';

class AppStartService extends StatelessWidget {
  const AppStartService({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;
  @override
  Widget build(BuildContext context) {
    final app = appDescriptor;
    final themeMode = appPreferenceManager.notifier.select((e) => e.themeMode);
    return ProviderScope(
      child: ListenableBuilder(
        listenable: themeMode,
        builder: (_, __) {
          return ShadApp.material(
            title: app.title,
            initialRoute: '/',
            theme: ShadThemeData(
              brightness: Brightness.light,
              colorScheme: const ShadZincColorScheme.light(),
            ),
            darkTheme: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: const ShadZincColorScheme.dark(),
            ),
            themeMode: themeMode.value,
            onGenerateRoute: (settings) {
              final uri = Uri.parse(settings.name ?? '');

              return PageRouteBuilder(
                transitionsBuilder: app.transitionBuilder,
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CLTheme(
                  colors: const DefaultCLColors(),
                  noteTheme: const DefaultNotesTheme(),
                  child: OnInitDone(
                    app: app,
                    uri: uri,
                    builder: () {
                      final screen = app.screens
                          .where(
                            (s) => s.name == uri.path.replaceFirst('/', ''),
                          )
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
          );
        },
      ),
    );
  }
}
