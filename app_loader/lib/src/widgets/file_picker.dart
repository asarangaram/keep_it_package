import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../shared_media/models/cl_shared_media.dart';
import '../shared_media/providers/incoming_media.dart';

Future<bool> onPickFiles(
  BuildContext context,
  WidgetRef ref, {
  Collection? collection,
}) async {
  final picker = ImagePicker();
  final pickedFileList = await picker.pickMultipleMedia();

  if (pickedFileList.isNotEmpty) {
    final items = pickedFileList
        .map(
          (xfile) => CLMedia(path: xfile.path, type: CLMediaType.file),
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
  }
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
