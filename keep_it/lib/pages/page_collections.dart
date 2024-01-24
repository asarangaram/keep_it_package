import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../views/collections_view.dart';
import '../widgets/load_from_store.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const CLFullscreenBox(
        child: CLBackground(
          child: LoadCollections(
            buildOnData: CollectionsView.new,
          ),
        ),
      );
}
