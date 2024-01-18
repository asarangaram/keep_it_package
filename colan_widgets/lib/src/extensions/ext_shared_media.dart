/// Converts SharedMedia to CLMediaInfoGroup
library;

import 'package:share_handler/share_handler.dart';

import '../utils/file_handler.dart';
import '../utils/media/cl_media.dart';
import '../utils/media/cl_media_image.dart';
import '../utils/media/cl_media_type.dart';
import '../utils/media/cl_media_video.dart';

import '../utils/url_handler.dart';
import 'ext_string.dart';

extension FromSharedMediaGroup on SharedMedia? {
  CLMediaType toCLMediaType(SharedAttachmentType type) {
    return switch (type) {
      SharedAttachmentType.image => CLMediaType.image,
      SharedAttachmentType.video => CLMediaType.video,
      SharedAttachmentType.audio => CLMediaType.audio,
      SharedAttachmentType.file => CLMediaType.file,
    };
  }

  Future<CLMediaInfoGroup> toCLMediaInfoGroup() async {
    if (this == null) {
      throw Exception('No Shared Items found');
    }
    final newMedia = <CLMedia>[];
    if (this!.content?.isNotEmpty ?? false) {
      final text = this!.content!;
      if (text.isURL()) {
        final mimeType = await URLHandler.getMimeType(text);

        final r = switch (mimeType) {
          CLMediaType.image ||
          CLMediaType.audio ||
          CLMediaType.video ||
          CLMediaType.file =>
            await URLHandler.downloadAndSaveImage(text),
          _ => null
        };
        if (r == null) {
          newMedia.add(CLMedia(path: text, type: CLMediaType.url));
        } else {
          newMedia.add(
            switch (mimeType) {
              CLMediaType.image => await CLMediaImage(
                  path: text,
                  type: CLMediaType.image,
                  url: text,
                ).withPreview(),
              null => throw Exception('Unexpected null'),
              _ => CLMedia(
                  path: r,
                  type: mimeType,
                )
            },
          );
        }
      }
    }
    if (this!.imageFilePath != null) {
      newMedia.add(
        await CLMediaImage(
          path: await FileHandler.move(
            this!.imageFilePath!,
            toDir: 'Incoming',
          ),
          type: CLMediaType.image,
        ).withPreview(),
      );
    }
    if (this!.attachments?.isNotEmpty ?? false) {
      for (final e in this!.attachments!) {
        if (e != null) {
          newMedia.add(
            switch (e.type) {
              SharedAttachmentType.image => await CLMediaImage(
                  path: await FileHandler.move(
                    e.path,
                    toDir: 'Incoming',
                  ),
                  type: CLMediaType.image,
                ).withPreview(),
              SharedAttachmentType.video => await CLMediaVideo(
                  path: await FileHandler.move(
                    e.path,
                    toDir: 'Incoming',
                  ),
                  type: CLMediaType.image,
                ).withPreview(),
              _ => CLMedia(path: e.path, type: toCLMediaType(e.type)),
            },
          );
        }
      }
    }

    return CLMediaInfoGroup(newMedia)..toString().printString();
  }
}
