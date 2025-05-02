import 'package:flutter/material.dart';

import '../notifier/ui_state.dart';
import 'bottom_bar.dart';
import 'media_viewer_core.dart';
import 'top_bar.dart';

class MViewerMainScreen extends StatelessWidget {
  const MViewerMainScreen({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    const iconColor = Color.fromARGB(255, 80, 140, 224);
    final showMenu = uiStateManager.notifier.select((state) => state.showMenu);

    const topBar = TopBar(iconColor: iconColor);
    const bottomBar = BottomBar(iconColor: iconColor);

    return ListenableBuilder(
      listenable: showMenu,
      child: MediaViewerCore(
        parentIdentifier: parentIdentifier,
      ),
      builder: (_, child) {
        return Scaffold(
          backgroundColor: showMenu.value ? null : Colors.black,
          appBar: showMenu.value ? topBar : null,
          body: SafeArea(child: child!),
          bottomNavigationBar: showMenu.value ? bottomBar : null,
        );
      },
    );
  }
}
