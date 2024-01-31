import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

Future<bool> onPickImages(BuildContext context, WidgetRef ref) async {
  try {
    final picker = ImagePicker();

    final pickedFileList = await picker.pickMultipleMedia();

    if (pickedFileList.isNotEmpty) {
      final media = <CLMedia>[];
      for (final item in pickedFileList) {
        media.add(
          await switch (lookupMimeType(item.path)) {
            (final String mime) when mime.startsWith('image') =>
              CLMediaImage(path: item.path),
            (final String mime) when mime.startsWith('video') =>
              CLMediaVideo(path: item.path),
            (final String mime) when mime.startsWith('audio') =>
              CLMedia(path: item.path, type: CLMediaType.audio),
            _ => CLMedia(path: item.path, type: CLMediaType.file),
          }
              .withPreview(forceCreate: true),
        );
      }
      final infoGroup = CLMediaInfoGroup(media);
      ref.read(incomingMediaProvider.notifier).push(infoGroup);
    }

    return pickedFileList.isNotEmpty;
  } catch (e) {
    // I don't know if this will ever occur.
    // Will it come here when use cancels?
    // if so, we can simply ignore this.
    throw Exception('gPickImage Unexpected Failure');
  }
}
