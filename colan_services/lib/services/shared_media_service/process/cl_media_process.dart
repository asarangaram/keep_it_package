import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:path/path.dart' as path;
import 'package:store/store.dart';

import '../models/cl_shared_media.dart';

class CLMediaProcess {
  static Stream<Progress> analyseMedia({
    required DBManager dbManager,
    required CLSharedMedia media,
    required Future<CLMedia?> Function(String md5) findItemByMD5,
    required AppSettings appSettings,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: path.basename(media.entries[0].path),
      fractCompleted: 0,
    );
    for (final (i, item0) in media.entries.indexed) {
      final item1 = await ExtDeviceProcessMedia.tryDownloadMedia(
        item0,
        appSettings: appSettings,
      );
      final item = await ExtDeviceProcessMedia.identifyMediaType(
        item1,
        appSettings: appSettings,
      );
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(item.path);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await findItemByMD5(md5String);
          if (duplicate != null) {
            candidates.add(duplicate);
          } else {
            const tempCollectionName = '*** Recently Imported';
            final Collection tempCollection;
            tempCollection =
                await dbManager.getCollectionByLabel(tempCollectionName) ??
                    await dbManager.upsertCollection(
                      collection: const Collection(label: tempCollectionName),
                    );
            final newMedia = CLMedia(
              path: item.path,
              type: item.type,
              collectionId: tempCollection.id,
              md5String: md5String,
              isHidden: true,
            );
            final tempMedia = await dbManager.upsertMedia(
              collectionId: tempCollection.id!,
              media: newMedia.copyWith(isHidden: true),
              onPrepareMedia: (m, {required targetDir}) async {
                final updated =
                    (await m.moveFile(targetDir: targetDir)).getMetadata();
                return updated;
              },
            );
            if (tempMedia != null) {
              candidates.add(tempMedia);
            } else {
              /* Failed to add media, handle here */
            }
          }
        } else {
          /* Missing file? ignoring */
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
    await Future<void>.delayed(const Duration(milliseconds: 10));
    onDone(
      mg: CLSharedMedia(entries: candidates, collection: media.collection),
    );
  }
}

const _filePrefix = 'Media Processing: ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
