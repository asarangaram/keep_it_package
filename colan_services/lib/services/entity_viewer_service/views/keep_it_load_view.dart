import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/on_swipe.dart';
import 'top_bar.dart';

class KeepItLoadView extends ConsumerWidget {
  const KeepItLoadView({required this.parentIdentifier, super.key});
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLScaffold(
        topMenu: TopBar(
            viewIdentifier: ViewIdentifier(
                parentID: parentIdentifier, viewIdDELETED: 'Loading'),
            entityAsync: const AsyncLoading(),
            children: null),
        bottomMenu: null,
        banners: const [],
        body: OnSwipe(child: CLLoader.widget(debugMessage: null)));
  }
}
