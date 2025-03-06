import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;

import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:server/server.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'views/registerred_server_view.dart';
import 'views/server_selector_view.dart';

void main() {
  runApp(Solid(
      providers: [
        Provider<Signal<ThemeMode>>(create: () => Signal(ThemeMode.light)),
      ],
      builder: (context) {
        final themeMode = context.observe<ThemeMode>();
        return ShadApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeMode,
          theme: ShadThemeData(
            brightness: Brightness.light,
            colorScheme: const ShadZincColorScheme.light(),
          ),
          darkTheme: ShadThemeData(
            brightness: Brightness.dark,
            colorScheme: const ShadZincColorScheme.dark(),
          ),
          home: riverpod.ProviderScope(child: MainApp()),
        );
      }));
}

class MainApp extends riverpod.ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, riverpod.WidgetRef ref) {
    final server = ref.watch(serverProvider);

    if ((server.isRegistered)) {
      return const RegisterredServerView();
    } else {
      return ServerSelectorView();
    }
  }
}
