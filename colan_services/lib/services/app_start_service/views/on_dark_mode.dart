import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../notifiers/app_preferences.dart' show appPreferenceProvider;

class OnDarkMode extends ConsumerWidget {
  const OnDarkMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode =
        ref.watch(appPreferenceProvider.select((e) => e.themeMode));
    return ShadButton.ghost(
      onPressed: () {
        switch (themeMode) {
          case ThemeMode.system:
            throw UnimplementedError();
          case ThemeMode.light:
            ref.read(appPreferenceProvider.notifier).themeMode = ThemeMode.dark;
          case ThemeMode.dark:
            ref.read(appPreferenceProvider.notifier).themeMode =
                ThemeMode.light;
        }
      },
      child: switch (themeMode) {
        ThemeMode.system => throw UnimplementedError(),
        ThemeMode.light => clIcons.lightMode.iconFormatted(),
        ThemeMode.dark => clIcons.darkMode.iconFormatted(),
      },
    );
  }
}
