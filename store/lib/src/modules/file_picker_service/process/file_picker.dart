import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../media_wizard_service/models/cl_shared_media.dart';
import '../../media_wizard_service/models/universal_media_source.dart';
import '../widgets/incoming_media_monitor.dart';

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
    final sharedMedia = CLSharedMedia(
      entries: items,
      collection: collection,
      type: UniversalMediaSource.filePick,
    );

    if (items.isNotEmpty) {
      IncomingMediaMonitor.pushMedia(ref, sharedMedia);
    }

    return items.isNotEmpty;
  } else {
    return false;
    // User canceled the picker
  }
}
