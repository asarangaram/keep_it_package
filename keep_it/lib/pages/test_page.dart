import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/providers/theme.dart';
import 'views/collection_list_view.dart';

class TestPage extends ConsumerWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return CLFullscreenBox(
        backgroundColor: theme.colorTheme.backgroundColor,
        hasBorder: true,
        useSafeArea: true,
        child: const Center(child: TestButton()));
  }
}

class TestButton extends ConsumerWidget {
  const TestButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(themeProvider);
    return Center(
      child: CLButtonElevatedText.large(
        "show Dialog",
        color: theme.colorTheme.textColor,
        disabledColor: theme.colorTheme.disabledColor,
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
