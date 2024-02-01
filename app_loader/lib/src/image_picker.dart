import 'package:app_loader/src/models/incoming_media_stream.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

Future<bool> onPickImages(
  BuildContext context,
  WidgetRef ref, {
  int? collectionId,
}) async {
  try {
    final picker = ImagePicker();

    final pickedFileList = await picker.pickMultipleMedia();

    await ref.read(incomingMediaStreamProvider.notifier).onInsertFiles(
          pickedFileList.map((e) => e.path).toList(),
          collectionId: collectionId,
        );

    return pickedFileList.isNotEmpty;
  } catch (e) {
    // I don't know if this will ever occur.
    // Will it come here when use cancels?
    // if so, we can simply ignore this.
    throw Exception('gPickImage Unexpected Failure');
  }
}
