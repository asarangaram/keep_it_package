import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/load_from_store/load_collections.dart';
import 'views/collections_page/collections_view.dart';

class CollectionsPage extends ConsumerWidget {
  const CollectionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadCollections(
        buildOnData: (collections) => CollectionsView(collections),
      );
}
