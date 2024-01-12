import 'package:colan_widgets/colan_widgets.dart';

import 'package:share_handler/share_handler.dart';

extension FromSharedMediaGroup on SharedMedia? {
  Future<CLMediaInfoGroup> toCLMediaInfoGroup() async {
    if (this == null) {
      throw Exception('No Shared Items found');
    }
    final newMedia = <CLMediaImage>[];
    if (this!.content?.isNotEmpty ?? false) {
      final text = this!.content!;
      if (text.isURL()) {
        final mimeType = await URLHandler.getMimeType(text);
        switch (mimeType) {
          case CLMediaType.image:
          case CLMediaType.audio:
          case CLMediaType.video:
          case CLMediaType.file:
            final r = await URLHandler.downloadAndSaveImage(text);
            if (r != null) {
              newMedia.add(CLMediaImage(path: r, type: mimeType!));
            } else {
              //retain as url
              newMedia.add(
                CLMediaImage(
                  path: text,
                  type: CLMediaType.url,
                ),
              );
            }
          case CLMediaType.url:
          case CLMediaType.text: // This shouldn't appear
          case null:
            newMedia.add(
              CLMediaImage(
                path: text,
                type: CLMediaType.url,
              ),
            );
        }
      } else {
        newMedia.add(
          CLMediaImage(
            path: text,
            type: CLMediaType.text,
          ),
        );
      }
    }
    if (this!.imageFilePath != null) {
      newMedia.add(
        CLMediaImage(
          path: this!.imageFilePath!,
          type: CLMediaType.image,
        ),
      );
    }
    if (this!.attachments?.isNotEmpty ?? false) {
      for (final e in this!.attachments!) {
        if (e != null) {
          newMedia.add(
            CLMediaImage(
              path: e.path,
              type: switch (e.type) {
                SharedAttachmentType.image => CLMediaType.image,
                SharedAttachmentType.video => CLMediaType.video,
                SharedAttachmentType.audio => CLMediaType.audio,
                SharedAttachmentType.file => CLMediaType.file,
              },
            ),
          );
        }
      }
    }

    return CLMediaInfoGroup(newMedia);
  }
}
