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
    return Scaffold(
      // backgroundColor:  Colors.white, // ShadTheme.of(context).colorScheme.background,
      appBar: const TopBar(iconColor: iconColor),
      // extendBodyBehindAppBar: true,
      //extendBody: true,
      body: SafeArea(
        child: MediaViewerCore(
          parentIdentifier: parentIdentifier,
        ),
      ),
      bottomNavigationBar: const BottomBar(iconColor: iconColor),
    );
  }
}
