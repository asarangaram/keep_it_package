import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifier/ui_state.dart';

import 'views/bottom_bar.dart';
import 'views/media_viewer_core.dart';
import 'views/top_bar.dart';

class MediaViewer extends ConsumerWidget {
  const MediaViewer({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const iconColor = Color.fromARGB(255, 80, 140, 224);
    final showMenu =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.showMenu));

    const topBar = TopBar(iconColor: iconColor);
    const bottomBar = BottomBar(iconColor: iconColor);

    return Scaffold(
      backgroundColor: showMenu ? null : Colors.black,
      appBar: showMenu ? topBar : null,
      body: SafeArea(
        child: MediaViewerCore(parentIdentifier: parentIdentifier),
      ),
      bottomNavigationBar: showMenu ? bottomBar : null,
    );
  }
}
