/* import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tab_identifier.dart';
import '../providers/page_controller.dart';

class GetPageControls extends ConsumerWidget {
  const GetPageControls(
      {super.key, required this.viewIdentifier, required this.builder});
  final ViewIdentifier viewIdentifier;
  final Widget Function(PageControls pageControl) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pageControllerNotifier =
        ref.watch(pageControllerProvider(viewIdentifier).notifier);
    return builder(pageControllerNotifier);
  }
}
 */
