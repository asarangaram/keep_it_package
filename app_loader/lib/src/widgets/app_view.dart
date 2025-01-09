import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_descriptor.dart';

class AppView extends ConsumerStatefulWidget {
  const AppView({
    required this.appDescriptor,
    super.key,
  });
  final AppDescriptor appDescriptor;

  @override
  ConsumerState<AppView> createState() => _RaLRouterState();
}

class _RaLRouterState extends ConsumerState<AppView>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //Does this work?
    if (state == AppLifecycleState.resumed) {
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = widget.appDescriptor;
    final themeMode = ref.watch(nightModeProvider);

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
      themeMode: themeMode,
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
          builder: (context) => IncomingMediaMonitor(
            onMedia: app.incomingMediaViewBuilder,
            child: screen.builder(context, uri.queryParameters),
          ),
        );
      },
    );
  }
}

final nightModeProvider = StateProvider<ThemeMode>((ref) {
  return ThemeMode.light;
});
