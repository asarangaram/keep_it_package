import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/timeline_view.dart';

class TagTimeLinePage extends ConsumerWidget {
  const TagTimeLinePage({required this.tagId, super.key});
  final int tagId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetTag(
      id: tagId,
      buildOnData: (tag) => GetMediaByTagId(
        tagID: tagId,
        buildOnData: (items) => TimeLineView(
          label: tag?.label ?? 'All Media',
          items: items,
          tagPrefix: 'Gallery View Media TagId: ${tag?.id}',
        ),
      ),
    );
  }
}
