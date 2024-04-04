import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../shared_media/models/cl_shared_media.dart';
import '../shared_media/providers/incoming_media.dart';

Future<bool> onPickFiles(
  BuildContext context,
  WidgetRef ref, {
  Collection? collection,
}) async {
  throw UnimplementedError();
/* 
  final result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    type: FileType.media,
  );

  if (result != null) {
    final items = result.paths
        .map(
          (path) => CLMedia(path: path!, type: CLMediaType.file),
        )
        .toList();
    final sharedMedia = CLSharedMedia(entries: items, collection: collection);

    if (items.isNotEmpty) {
      ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
    }

    return items.isNotEmpty;
  } else {
    return false;
    // User canceled the picker 
  }*/
}

Future<bool> onReceiveCapturedMedia(
  BuildContext context,
  WidgetRef ref, {
  required List<CLMedia> entries,
  Collection? collection,
}) async {
  if (entries.isNotEmpty) {
    final sharedMedia = CLSharedMedia(entries: entries, collection: collection);
    ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
    return true;
  }
  return false;
}
