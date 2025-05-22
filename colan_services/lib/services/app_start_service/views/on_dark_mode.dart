import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../notifiers/app_preferences.dart' show appPreferenceProvider;

class OnDarkMode extends ConsumerWidget {
  const OnDarkMode({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final iconColor =
        ref.watch(appPreferenceProvider.select((e) => e.iconColor));
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
      child: Icon(
        switch (themeMode) {
          ThemeMode.system => throw UnimplementedError(),
          ThemeMode.light => LucideIcons.sunMoon,
          ThemeMode.dark => LucideIcons.moon,
        },
        color: iconColor,
        size: 20,
      ),
    );
  }
}
