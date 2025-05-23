import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLEntitiesPageView extends ConsumerWidget {
  const CLEntitiesPageView({
    required this.parentIdentifier,
    required this.topMenu,
    required this.bottomMenu,
    super.key,
  });
  final String parentIdentifier;
  final PreferredSizeWidget topMenu;
  final PreferredSizeWidget bottomMenu;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showMenu =
        ref.watch(mediaViewerUIStateProvider.select((e) => e.showMenu));
    if (showMenu) {
      return CLScaffold(
        topMenu: topMenu,
        banners: const [],
        body: SafeArea(
          child: MediaViewerCore(parentIdentifier: parentIdentifier),
        ),
        bottomMenu: bottomMenu,
      );
    } else {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: MediaViewerCore(parentIdentifier: parentIdentifier),
        ),
      );
    }
  }
}
