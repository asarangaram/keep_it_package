import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;

import '../models/cl_media.dart';
import '../views/stream_progress_view.dart';

class CLMediaProcess {
  static Stream<Progress> analyseMedia(
    CLMediaInfoGroup media,
    void Function(CLMediaInfoGroup) onDone,
  ) async* {
    final updated = <CLMedia>[];
    yield Progress(
      currentItem: path.basename(media.list[0].path),
      fractCompleted: 0,
    );

    for (final (i, item) in media.list.indexed) {
      switch (item.type) {
        case CLMediaType.file:
          {
            final clMedia = switch (lookupMimeType(item.path)) {
              (final String mime) when mime.startsWith('image') => CLMedia(
                  path: item.path,
                  type: CLMediaType.image,
                  collectionId: media.targetID,
                ),
              (final String mime) when mime.startsWith('video') =>
                await ExtCLMediaFile.clMediaWithPreview(
                  path: item.path,
                  type: CLMediaType.video,
                  collectionId: media.targetID,
                ),
              _ => CLMedia(
                  path: item.path,
                  type: CLMediaType.file,
                  collectionId: media.targetID,
                ),
            };

            updated.add(clMedia);
          }
        case CLMediaType.image:
        case CLMediaType.video:
        case CLMediaType.url:
          updated.add(item);
        case CLMediaType.audio:
        case CLMediaType.text:
          break;
      }
      await Future<void>.delayed(const Duration(milliseconds: 100));

      yield Progress(
        currentItem: (i + 1 == media.list.length)
            ? ''
            : path.basename(media.list[i + 1].path),
        fractCompleted: (i + 1) / media.list.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    onDone(CLMediaInfoGroup(list: updated, targetID: media.targetID));
  }

  static Stream<Progress> acceptMedia({
    required CLMediaInfoGroup media,
    required void Function(CLMediaInfoGroup) onDone,
  }) async* {
    if (media.targetID == null) {
      throw Exception("targetID can't be null to accept");
    }
    final updated = <CLMedia>[];
    yield Progress(
      currentItem: path.basename(media.list[0].path),
      fractCompleted: 0,
    );
    for (final (i, item) in media.list.indexed) {
      updated.add(item.copyWith(collectionId: media.targetID));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield Progress(
        currentItem: (i + 1 == media.list.length)
            ? ''
            : path.basename(media.list[i + 1].path),
        fractCompleted: (i + 1) / media.list.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 100));
    onDone(CLMediaInfoGroup(list: updated, targetID: media.targetID));
  }
}
