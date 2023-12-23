import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/collections_page/collections_from_db.dart';
import 'views/collections_page/collections_view.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      useSafeArea: false,
      child: CollectionsFromDB(
          buildOnData: (collections) => CollectionsView(collections)),
    );
  }
}
