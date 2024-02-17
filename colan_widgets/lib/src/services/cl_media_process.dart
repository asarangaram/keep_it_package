import 'dart:io';

import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

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
            final clMedia = CLMedia(
              path: item.path,
              type: switch (lookupMimeType(item.path)) {
                (final String mime) when mime.startsWith('image') =>
                  CLMediaType.image,
                (final String mime) when mime.startsWith('video') =>
                  CLMediaType.video,
                _ => CLMediaType.file
              },
              collectionId: media.targetID,
            );

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
      await Future<void>.delayed(const Duration(milliseconds: 10));

      yield Progress(
        currentItem: (i + 1 == media.list.length)
            ? ''
            : path.basename(media.list[i + 1].path),
        fractCompleted: (i + 1) / media.list.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 10));
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
    final pathPrefix = await getApplicationDocumentsDirectory();
    for (final (i, item) in media.list.indexed) {
      updated.add(
        await (await item
                .copyWith(collectionId: media.targetID)
                .copyFile(pathPrefix: pathPrefix.path))
            .getMetadata(),
      );
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

extension ExtProcess on CLMedia {
  Future<CLMedia> getMetadata() async {
    DateTime? originalDate;
    if (type != CLMediaType.image) {
      return this;
    }
    try {
      if (id == null) {
        final fileBytes = File(this.path).readAsBytesSync();
        final data = await readExifFromBytes(fileBytes);

        var dateTimeString = data['EXIF DateTimeOriginal']!.printable;
        final dateAndTime = dateTimeString.split(' ');
        dateTimeString =
            [dateAndTime[0].replaceAll(':', '-'), dateAndTime[1]].join(' ');

        originalDate = DateTime.parse(dateTimeString);
        return copyWith(originalDate: originalDate);
      }
      // final md5String = await calculateMD5(File(item.path));
      // TODO(anandas): md5 compare and replace.
    } catch (e) {
      /*  */
    }
    return this;
  }
}
