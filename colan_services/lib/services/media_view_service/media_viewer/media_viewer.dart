import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'notifier/ui_state.dart';
import 'views/m_viewer_main_screen.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({super.key});

  @override
  Widget build(BuildContext context) {
    final lightColorScheme = ShadColorScheme.fromName('rose');
    final darkColorScheme = ShadColorScheme.fromName(
      'rose',
      brightness: Brightness.dark,
    );
    final isDartTheme = uiStateManager.notifier.select(
      (state) => state.isDartTheme,
    );
    return ListenableBuilder(
      listenable: isDartTheme,
      builder: (final _, final __) {
        return ShadApp(
          theme: ShadThemeData(
            colorScheme: lightColorScheme,
            brightness: Brightness.light,
          ),
          darkTheme: ShadThemeData(
            colorScheme: darkColorScheme,
            brightness: Brightness.dark,
          ),
          themeMode: isDartTheme.value ? ThemeMode.dark : ThemeMode.light,
          home: const MViewerMainScreen(),
        );
      },
    );
  }
}
