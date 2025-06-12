import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/on_swipe.dart';
import 'top_bar.dart';

class KeepItLoadView extends ConsumerWidget {
  const KeepItLoadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLScaffold(
        topMenu: const TopBar(
            serverId: null, entityAsync: AsyncLoading(), children: null),
        bottomMenu: null,
        banners: const [],
        body: OnSwipe(child: CLLoader.widget(debugMessage: null)));
  }
}
