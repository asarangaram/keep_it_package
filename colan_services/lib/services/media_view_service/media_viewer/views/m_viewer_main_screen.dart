import 'package:flutter/material.dart';

import '../notifier/ui_state.dart';
import 'bottom_bar.dart';
import 'media_viewer_core.dart';
import 'top_bar.dart';

class MViewerMainScreen extends StatelessWidget {
  const MViewerMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const iconColor = Color.fromARGB(255, 80, 140, 224);
    return SafeArea(
      top: false,
      bottom: false,
      left: false,
      right: false,
      child: Scaffold(
        // backgroundColor:  Colors.white, // ShadTheme.of(context).colorScheme.background,
        appBar: const TopBar(iconColor: iconColor),
        // extendBodyBehindAppBar: true,
        //extendBody: true,
        body: GestureDetector(
          onTap: uiStateManager.notifier.toggleMenu,
          child: const MediaViewerCore(),
        ),
        bottomNavigationBar: const BottomBar(iconColor: iconColor),
      ),
    );
  }
}
