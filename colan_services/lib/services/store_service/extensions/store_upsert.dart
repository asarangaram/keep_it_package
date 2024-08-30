import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../../settings_service/models/m1_app_settings.dart';
import '../extensions/store_utils.dart';
import '../models/store_manager.dart';
import '../models/url_handler.dart';
import 'store_reader.dart';

extension UpsertExtOnStoreManager on StoreManager {
  Future<Collection> upsertCollection(Collection collection) async {
    final updated = await store.upsertCollection(collection);
    return updated;
  }

  Future<CLMedia?> upsertMediaFromFile(
    String path,
    CLMediaType type, {
    int? id,
    int? collectionId,
    bool isAux = false,
    List<CLMedia>? parents,
  }) async {
    int? collectionId0;
    final Collection collection;
    final media = (id == null) ? null : await getMediaById(id);
    collectionId0 = collectionId ?? media?.collectionId;

    final existingCollection =
        collectionId0 == null ? null : await getCollectionById(collectionId0);
    collection = existingCollection ??
        await getCollectionByLabel(tempCollectionName) ??
        await store.upsertCollection(
          Collection(label: tempCollectionName),
        );

    final savedMediaFile =
        File(path).copyTo(appSettings.directories.media.path);

    final md5String = await File(path).checksum;
    final savedMedia = media?.copyWith(
          name: path_handler.basename(savedMediaFile.path),
          fExt: path_handler.extension(savedMediaFile.path),
          type: type,
          collectionId: collection.id,
          md5String: md5String,
          isHidden: existingCollection == null,
          isAux: isAux,
          isDeleted: false,
        ) ??
        CLMedia(
          name: path_handler.basename(savedMediaFile.path),
          fExt: path_handler.extension(savedMediaFile.path),
          type: type,
          collectionId: collection.id,
          md5String: md5String,
          isHidden: collectionId0 == null,
          isAux: isAux,
        );
    final mediaFromDB = await store.upsertMedia(savedMedia, parents: parents);
    if (mediaFromDB == null) {
      await File(
        path_handler.join(
          appSettings.directories.media.pathString,
          savedMedia.name,
        ),
      ).deleteIfExists();
    } else {
      await generatePreview(mediaFromDB);
      try {
        await File(path).deleteIfExists();
      } catch (e) {
        /** ignore if original path can't be deleted, it could be 
         * readonly
         */
      }
    }
    return mediaFromDB;
  }

  Future<CLMedia?> newImageOrVideo(
    String fileName, {
    required bool isVideo,
    Collection? collection,
  }) async =>
      upsertMediaFromFile(
        fileName,
        isVideo ? CLMediaType.video : CLMediaType.image,
      );

  Future<CLMedia> replaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final mediaFromDB = await upsertMediaFromFile(
      outFile,
      originalMedia.type,
      id: originalMedia.id,
      collectionId: originalMedia.collectionId,
    );

    return mediaFromDB ?? originalMedia;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final mediaFromDB = await upsertMediaFromFile(
      outFile,
      originalMedia.type,
      collectionId: originalMedia.collectionId,
    );

    return mediaFromDB ?? originalMedia;
  }

  Future<CLMediaBase> tryDownloadMedia(
    CLMediaBase mediaFile, {
    required AppSettings appSettings,
  }) async {
    if (mediaFile.type != CLMediaType.url) {
      return mediaFile;
    }
    final mimeType = await URLHandler.getMimeType(
      mediaFile.name,
    );
    if (![
      CLMediaType.image,
      CLMediaType.video,
      CLMediaType.audio,
      CLMediaType.file,
    ].contains(mimeType)) {
      return mediaFile;
    }
    final downloadedFile = await URLHandler.download(
      mediaFile.name,
      appSettings.directories.download.path,
    );
    if (downloadedFile == null) {
      return mediaFile;
    }
    return mediaFile.copyWith(name: downloadedFile, type: mimeType);
  }

  Future<CLMediaBase> identifyMediaType(
    CLMediaBase mediaFile, {
    required AppSettings appSettings,
  }) async {
    if (mediaFile.type != CLMediaType.file) {
      return mediaFile;
    }

    final mimeType = switch (lookupMimeType(mediaFile.name)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };
    if (mimeType == CLMediaType.file) {
      return mediaFile;
    }
    return mediaFile.copyWith(type: mimeType);
  }

  Future<void> upsertNote(
    String path,
    CLMediaType type, {
    required List<CLMedia> mediaMultiple,
    CLMedia? note,
  }) async =>
      upsertMediaFromFile(
        path,
        type,
        id: note?.id,
        isAux: true,
        parents: mediaMultiple,
      );
  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> mediaMultiple,
    }) onDone,
  }) async* {
    final candidates = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: path_handler.basename(mediaFiles[0].name),
      fractCompleted: 0,
    );
    for (final (i, item0) in mediaFiles.indexed) {
      final item1 = await tryDownloadMedia(
        item0,
        appSettings: appSettings,
      );
      final item = await identifyMediaType(
        item1,
        appSettings: appSettings,
      );
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(
          item.name,
        );
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await getMediaByMD5(md5String);
          if (duplicate != null) {
            candidates.add(duplicate);
          } else {
            final mediaFromDB = await upsertMediaFromFile(item.name, item.type);
            if (mediaFromDB != null) {
              candidates.add(mediaFromDB);
            } else {
              /* Failed to add media, handle here */
            }
          }
        } else {
          /* Missing file? ignoring */
        }
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));

      yield Progress(
        currentItem: (i + 1 == mediaFiles.length)
            ? ''
            : path_handler.basename(
                mediaFiles[i + 1].name,
              ),
        fractCompleted: (i + 1) / mediaFiles.length,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    onDone(
      mediaMultiple: candidates,
    );
  }
}
