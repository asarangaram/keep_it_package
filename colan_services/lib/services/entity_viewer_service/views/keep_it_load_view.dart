import 'package:colan_services/services/entity_viewer_service/widgets/on_swipe.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class KeepItLoadView extends ConsumerWidget {
  const KeepItLoadView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnSwipe(
        child: Scaffold(body: CLLoader.widget(debugMessage: 'GetEntity')));
  }
}
