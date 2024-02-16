import 'package:colan_widgets/colan_widgets.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/incoming_media.dart';

Future<bool> onPickFiles(
  BuildContext context,
  WidgetRef ref, {
  int? collectionId,
}) async {
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
    final sharedMedia = CLMediaInfoGroup(list: items, targetID: collectionId);

    if (items.isNotEmpty) {
      ref.read(incomingMediaStreamProvider.notifier).push(sharedMedia);
    }

    return items.isNotEmpty;
  } else {
    return false;
    // User canceled the picker
  }
}
