import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:exif/exif.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/cl_media.dart';
import '../views/stream_progress_view.dart';

class CLMediaProcess {
  static Stream<Progress> analyseMedia({
    required CLMediaList media,
    required Future<CLMedia?> Function(String md5) findItemByMD5,
    required void Function({
      required CLMediaList mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];

    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );
    Future<String> getFileChecksum(File file) async {
      try {
        final stream = file.openRead();
        final hash = await md5.bind(stream).first;

        // NOTE: You might not need to convert it to base64
        return hash.toString();
      } catch (exception) {
        throw Exception('unable to determine md5');
      }
    }

    for (final (i, item) in media.entries.indexed) {
      final file = File(item.path);
      if (file.existsSync()) {
        final md5String = await getFileChecksum(file);
        final duplicate = await findItemByMD5(md5String);
        if (duplicate != null) {
          candidates.add(duplicate);
        } else {
          final CLMedia itemsToAdd;
          switch (item.type) {
            case CLMediaType.file:
              {
                itemsToAdd = CLMedia(
                  path: item.path,
                  type: switch (lookupMimeType(item.path)) {
                    (final String mime) when mime.startsWith('image') =>
                      CLMediaType.image,
                    (final String mime) when mime.startsWith('video') =>
                      CLMediaType.video,
                    _ => CLMediaType.file
                  },
                  collectionId: media.targetID,
                  md5String: md5String,
                );
              }
            case CLMediaType.image:
            case CLMediaType.video:
            case CLMediaType.url:
            case CLMediaType.audio:
            case CLMediaType.text:
              {
                itemsToAdd = CLMedia(
                  path: item.path,
                  type: item.type,
                  collectionId: media.targetID,
                  md5String: md5String,
                );
              }
          }

          candidates.add(itemsToAdd);
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 10));

      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? ''
            : path.basename(media.entries[i + 1].path),
        fractCompleted: (i + 1) / media.entries.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));
    onDone(
      mg: CLMediaList(entries: candidates, targetID: media.targetID),
    );
  }

  static Stream<Progress> acceptMedia({
    required CLMediaList media,
    required void Function(CLMediaList) onDone,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async* {
    if (media.targetID == null) {
      throw Exception("targetID can't be null to accept");
    }

    final updated = <CLMedia>[];
    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );
    final pathPrefix = await getApplicationDocumentsDirectory();
    for (final (i, item0) in media.entries.indexed) {
      final item = item0;
      updated.add(
        await (await item
                .copyWith(collectionId: media.targetID)
                .copyFile(pathPrefix: pathPrefix.path))
            .getMetadata(),
      );
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? ''
            : path.basename(media.entries[i + 1].path),
        fractCompleted: (i + 1) / media.entries.length,
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 200));

    onDone(CLMediaList(entries: updated, targetID: media.targetID));
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
