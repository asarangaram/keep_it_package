import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

Future<bool> onPickImages(
  BuildContext context,
  WidgetRef ref, {
  int? collectionId,
}) async {
  try {
    final picker = ImagePicker();

    final pickedFileList = await picker.pickMultipleMedia();

    if (pickedFileList.isNotEmpty) {
      final media = <CLMedia>[];
      for (final item in pickedFileList) {
        final clMedia = switch (lookupMimeType(item.path)) {
          (final String mime) when mime.startsWith('image') =>
            await ExtCLMediaFile.clMediaWithPreview(
              path: item.path,
              type: CLMediaType.image,
            ),
          (final String mime) when mime.startsWith('video') =>
            await ExtCLMediaFile.clMediaWithPreview(
              path: item.path,
              type: CLMediaType.video,
            ),
          (final String mime) when mime.startsWith('audio') =>
            CLMedia(path: item.path, type: CLMediaType.audio),
          _ => CLMedia(path: item.path, type: CLMediaType.file),
        };

        media.add(clMedia);
      }
      final infoGroup = CLMediaInfoGroup(media, targetID: collectionId);
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
