import 'package:flutter/material.dart';

import 'notifier/ui_state.dart';
import 'views/m_viewer_main_screen.dart';

class MediaViewer extends StatelessWidget {
  const MediaViewer({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    //FIXME
    /*  final lightColorScheme = ShadColorScheme.fromName('rose');
    final darkColorScheme = ShadColorScheme.fromName(
      'rose',
      brightness: Brightness.dark,
    ); */
    final isDartTheme = uiStateManager.notifier.select(
      (state) => state.isDartTheme,
    );
    return ListenableBuilder(
      listenable: isDartTheme,
      builder: (_, __) {
        return MViewerMainScreen(parentIdentifier: parentIdentifier);
        /* return ShadApp(
          theme: ShadThemeData(
            colorScheme: lightColorScheme,
            brightness: Brightness.light,
          ),
          darkTheme: ShadThemeData(
            colorScheme: darkColorScheme,
            brightness: Brightness.dark,
          ),
          themeMode: isDartTheme.value ? ThemeMode.dark : ThemeMode.light,
          home: MViewerMainScreen(parentIdentifier: parentIdentifier),
        ); */
      },
    );
  }
}
