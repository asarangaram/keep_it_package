import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/cl_media.dart';
import '../views/stream_progress_view.dart';

class CLMediaProcess {
  static Stream<Progress> analyseMedia(
    CLMediaBaseInfoGroup media,
    void Function(CLMediaInfoGroup) onDone,
  ) async* {
    final updated = <CLMedia>[];
    yield Progress(
      currentItem: path.basename(media.list[0].path),
      fractCompleted: 0,
    );

    for (final (i, item) in media.list.indexed) {
      final CLMedia updatedItem;
      final file = File(item.path);
      final contents = await file.readAsBytes();
      final md5String = md5.convert(contents);

      switch (item.type) {
        case CLMediaType.file:
          {
            updatedItem = CLMedia(
              path: item.path,
              type: switch (lookupMimeType(item.path)) {
                (final String mime) when mime.startsWith('image') =>
                  CLMediaType.image,
                (final String mime) when mime.startsWith('video') =>
                  CLMediaType.video,
                _ => CLMediaType.file
              },
              collectionId: media.targetID,
              md5String: md5String.toString(),
            );
          }
        case CLMediaType.image:
        case CLMediaType.video:
        case CLMediaType.url:
        case CLMediaType.audio:
        case CLMediaType.text:
          {
            updatedItem = CLMedia(
              path: item.path,
              type: item.type,
              collectionId: media.targetID,
              md5String: md5String.toString(),
            );
          }
      }

      updated.add(updatedItem);

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
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
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
    for (final (i, item0) in media.list.indexed) {
      final item = item0;
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
    } catch (e) {
      /*  */
    }
    return this;
  }
}
