import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/on_swipe.dart';
import 'top_bar.dart';

class KeepItLoadView extends ConsumerWidget {
  const KeepItLoadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnSwipe(
        child: CLScaffold(
            topMenu: const TopBar(
                viewIdentifier:
                    ViewIdentifier(parentID: 'Test', viewId: 'Loading'),
                entityAsync: AsyncLoading(),
                children: null),
            bottomMenu: null,
            banners: const [],
            body: CLLoader.widget(debugMessage: null)));
  }
}
