import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/collection_list_view.dart';

class DemoPage extends ConsumerWidget {
  const DemoPage({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(useSafeArea: true, child: child);
  }
}

//EmptyViewCollection()

class TestButton extends ConsumerWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: CLButtonElevatedText.large(
        "show Dialog",
        boxDecoration: BoxDecoration(border: Border.all()),
        onTap: () => showDialog<void>(
          context: context,
          builder: (BuildContext context) {
            return CollectionListViewDialog.fromDBSelectable(
              clusterID: null,
              onSelectionDone: (l) {
                debugPrint(l.map((e) => e.label).join(","));
                Navigator.of(context).pop();
              },
              onSelectionCancel: () {
                debugPrint("dialog cancelled");
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}
