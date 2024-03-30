import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
          onTapMedia: (
            int mediaId, {
            required String parentIdentifier,
          }) async {
            unawaited(
              context.push(
                '/item_by_tag/$tagId/$mediaId?parentIdentifier=$parentIdentifier',
              ),
            );
            return true;
          },
          items: items,
          parentIdentifier: 'Gallery View Media TagId: ${tag?.id}',
        ),
      ),
    );
  }
}
