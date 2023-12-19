import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/theme.dart';
import 'views/collections_page/collection_ideas.dart';

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
