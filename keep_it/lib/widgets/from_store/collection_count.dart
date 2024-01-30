import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'load_collections.dart';

// TODO(anandas): Can we query CollectionCount from DB?
class CollectionCount extends ConsumerWidget {
  const CollectionCount({
    required this.tagId,
    required this.buildOnData,
    super.key,
  });
  final int? tagId;

  final Widget Function(int count) buildOnData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadCollections(
      tagId: tagId,
      buildOnData: (collections) {
        return buildOnData(collections.entries.length);
      },
    );
  }
}
