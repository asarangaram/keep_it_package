import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../../app_start_service/notifiers/app_preferences.dart'
    show appPreferenceManager;

class OnDarkMode extends StatelessWidget {
  const OnDarkMode({required this.iconColor, super.key});

  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final isDartTheme = appPreferenceManager.notifier.select(
      (state) => state.themeMode,
    );
    return ListenableBuilder(
      listenable: isDartTheme,
      builder: (_, __) {
        return ShadButton.ghost(
          onPressed: () {
            switch (isDartTheme.value) {
              case ThemeMode.system:
                throw UnimplementedError();
              case ThemeMode.light:
                appPreferenceManager.notifier.themeMode = ThemeMode.dark;
              case ThemeMode.dark:
                appPreferenceManager.notifier.themeMode = ThemeMode.light;
            }
          },
          child: Icon(
            switch (isDartTheme.value) {
              ThemeMode.system => throw UnimplementedError(),
              ThemeMode.light => LucideIcons.sunMoon,
              ThemeMode.dark => LucideIcons.moon,
            },
            color: iconColor,
            size: 20,
          ),
        );
      },
    );
  }
}
