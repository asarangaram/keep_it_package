import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store_tasks/store_tasks.dart';

import '../providers/universal_media.dart';
import 'select_and_keep_media.dart';

class MediaWizardService0 extends ConsumerWidget {
  const MediaWizardService0(
      {required this.type, required this.onCancel, super.key});
  final String? type;
  final void Function() onCancel;

  static Future<void> addMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLSharedMedia media,
  }) async {
    ref
        .read(
          universalMediaProvider(
            media.type ?? UniversalMediaSource.unclassified,
          ).notifier,
        )
        .mediaGroup = media;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UniversalMediaSource source;
    if (type != null) {
      source = UniversalMediaSource.values.asNameMap()[type] ??
          UniversalMediaSource.unclassified;
    } else {
      source = UniversalMediaSource.unclassified;
    }
    final media = ref.watch(universalMediaProvider(source));
    if (media.isEmpty) {
      throw Exception('Nothing to show');
    }

    return CLEntitiesGridViewScope(
      child: SelectAndKeepMedia(
        onCancel: onCancel,
        media: media,
        type: source,
      ),
    );
  }
}
