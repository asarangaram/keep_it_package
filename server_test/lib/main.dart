import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' as riverpod;
import 'package:flutter_solidart/flutter_solidart.dart';
import 'package:server_test/media_list_screen.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
          home: riverpod.ProviderScope(child: MediaListScreen()),
        );
      }));
}
