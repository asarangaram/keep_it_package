import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import 'cl_media_view.dart';

class ItemPage extends ConsumerWidget {
  const ItemPage({required this.id, required this.collectionId, super.key});
  final int collectionId;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionId,
      buildOnData: (Items items) {
        final media = items.entries.where((e) => e.id == id).first;
        return CLMediaView(media: media);
      },
    );
  }
}
