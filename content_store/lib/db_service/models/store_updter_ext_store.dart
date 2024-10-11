// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../extensions/ext_cldirectories.dart';
import '../../extensions/list_ext.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

import 'share_files.dart';
import 'store_updater.dart';
import 'url_handler.dart';

extension StoreExt on StoreUpdater {
  Future<bool> deleteCollectionById(int id) async {
    final mediaMultiple = await store.reader.getMediaByCollectionId(id);

    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: () => true,
          isEdited: true,
        ),
      );
    }
    store.reloadStore();
    return true;
  }

  Future<bool> deleteMediaById(int id) async {
    final m = await store.reader.getMediaById(id);
    if (m != null) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: () => true,
          isEdited: true,
        ),
      );
    }
    store.reloadStore();
    return true;
  }

  Future<bool> deleteMediaMultipleById(Set<int> ids2Delete) async {
    final mediaMultiple =
        await store.reader.getMediasByIDList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: () => true,
          isEdited: true,
        ),
      );
    }
    store.reloadStore();
    return true;
  }

  Future<bool> restoreMediaMultipleById(Set<int> ids2Delete) async {
    final mediaMultiple =
        await store.reader.getMediasByIDList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: () => false,
          isEdited: true,
        ),
      );
    }
    store.reloadStore();
    return true;
  }

  Future<bool> permanentlyDeleteMediaMultipleById(Set<int> ids2Delete) async {
    final mediaMultiple =
        await store.reader.getMediasByIDList(ids2Delete.toList());

    // Gather Notes

    if (mediaMultiple.isNotEmpty) {
      final notes = <CLMedia>{};
      for (final m in mediaMultiple) {
        notes.addAll(await store.reader.getNotesByMediaId(m.id!));
      }

      final medias2Remove = [...mediaMultiple, ...notes];
      for (final m in medias2Remove) {
        await store.deleteMedia(m);
        await File(directories.getMediaAbsolutePath(m)).deleteIfExists();
        await File(directories.getPreviewAbsolutePath(m)).deleteIfExists();
      }
    }
    store.reloadStore();
    return true;
  }

  Future<bool> togglePinById(int id) async {
    return togglePinMultipleById({id});
  }

  Future<bool> togglePinMultipleById(Set<int?> ids2Delete) async {
    final media =
        await store.reader.getMediasByIDList(ids2Delete.nonNullableList);
    final bool res;
    if (media.any((e) => e.pin == null)) {
      res = await pinMediaMultiple(media);
    } else {
      res = await removePinMediaMultiple(media);
    }
    store.reloadStore();
    return res;
  }

  Future<bool> removePinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await albumManager.removeMultipleMedia(
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      for (final m in pinnedMedia) {
        await store.upsertMedia(m.updateStatus(pin: () => null));
      }
    }
    store.reloadStore();
    return res;
  }

  Future<bool> pinMediaMultiple(
    List<CLMedia> mediaMultiple,
  ) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          p.join(
            directories.media.pathString,
            media.name,
          ),
          title: media.name,
          isImage: media.type == CLMediaType.image,
          isVideo: media.type == CLMediaType.video,
          desc: 'KeepIT',
        );
        if (pin != null) {
          updatedMedia.add(media.updateStatus(pin: () => pin));
        }
      }
    }
    for (final m in updatedMedia) {
      await store.upsertMedia(m);
    }
    store.reloadStore();
    return true;
  }

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);
    store.reloadStore();
    return res;
  }

  String createTempFile({required String ext}) {
    final dir = directories.download.path; // FIXME temp Directory
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  Future<Collection> upsertCollection(Collection collection) async {
    if (collection.id != null) {
      final c = await store.reader.getCollectionById(collection.id!);
      if (collection == c) return collection;
    }
    final updated = store.upsertCollection(collection);
    store.reloadStore();
    return updated;
  }

  Future<CLMedia?> newMedia(
    String path, {
    required CLMediaType type,
    ValueGetter<String>? fExt,
    ValueGetter<String>? name,
    ValueGetter<String?>? ref,
    ValueGetter<DateTime?>? originalDate,
    /* ValueGetter<DateTime?>? createdDate,
    ValueGetter<DateTime?>? updatedDate, */
    /*  ValueGetter<String?>? md5String, */
    ValueGetter<bool?>? isDeleted,
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    /* ValueGetter<int?>? id, */
    ValueGetter<bool>? isPreviewCached,
    ValueGetter<bool>? isMediaCached,
    ValueGetter<String?>? previewLog,
    ValueGetter<String?>? mediaLog,
    ValueGetter<bool>? isMediaOriginal,
    ValueGetter<int?>? serverUID,
    ValueGetter<bool>? isEdited,
    ValueGetter<bool>? haveItOffline,
    ValueGetter<bool>? mustDownloadOriginal,
    List<CLMedia>? parents,
  }) async {
    final defaultName = name != null ? name() : p.basename(path);
    final computedMD5String = await File(path).checksum;
    final isAux0 = isAux?.call() ?? false;
    final collectionId0 = collectionId != null ? collectionId() : null;
    final int collectionId1;
    final bool? isHidden0;
    if (collectionId0 == null) {
      collectionId1 =
          (isAux0 ? (await _notesCollection) : (await _defaultCollection)).id!;
      isHidden0 = true;
    } else {
      collectionId1 = collectionId0;
      isHidden0 = null;
    }
    final pathExt = p.extension(path);
    final String fExt0;
    if (pathExt.replaceAll('.', '').isEmpty) {
      fExt0 = 'unknown';
    } else {
      fExt0 = fExt != null ? fExt() : p.extension(path);
    }

    final updated0 = CLMedia.strict(
      id: null,
      md5String: computedMD5String,
      name: defaultName,
      type: type,
      collectionId: collectionId1,
      isHidden: isHidden0 ?? (isHidden != null ? isHidden() : false),

      fExt: fExt0,
      isAux: isAux0,
      // Set defaults if not provided
      isPreviewCached: isPreviewCached?.call() ?? false,
      isMediaCached: isMediaCached?.call() ?? false,
      isMediaOriginal: isMediaOriginal?.call() ?? false,
      isEdited: isEdited?.call() ?? false,
      previewLog: previewLog != null ? previewLog() : null,
      mediaLog: mediaLog != null ? mediaLog() : null,
      serverUID: serverUID != null ? serverUID() : null,
      haveItOffline: haveItOffline?.call() ?? true,
      mustDownloadOriginal: mustDownloadOriginal?.call() ?? false,
      ref: ref != null ? ref() : null,
      originalDate: originalDate != null ? originalDate() : null,
      isDeleted: isDeleted != null ? isDeleted() : false,

      pin: pin != null ? pin() : null,
    );
    return upsertMedia(
      updated0,
      parents: parents,
      path: path,
    );
  }

  Future<CLMedia?> updateMedia(
    CLMedia media, {
    required bool isEdited,
    String? path,
    CLMediaType? type,
    ValueGetter<String>? fExt,
    ValueGetter<String>? name,
    ValueGetter<String?>? ref,
    ValueGetter<DateTime?>? originalDate,
    ValueGetter<DateTime?>? createdDate,
    ValueGetter<DateTime?>? updatedDate,
    /*  ValueGetter<String?>? md5String, */
    ValueGetter<bool?>? isDeleted,
    ValueGetter<bool?>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? collectionId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id, // id is overwritten only to clone
    ValueGetter<bool>? isPreviewCached,
    ValueGetter<bool>? isMediaCached,
    ValueGetter<String?>? previewLog,
    ValueGetter<String?>? mediaLog,
    ValueGetter<bool>? isMediaOriginal,
    ValueGetter<int?>? serverUID,
    ValueGetter<bool>? haveItOffline,
    ValueGetter<bool>? mustDownloadOriginal,
    List<CLMedia>? parents,
  }) async {
    if (media.pin != null && path == null) {
      throw Exception('Remove pin before updating media');
    }
    if (id != null && id() != null) {
      throw Exception('id can only be cleared');
    }

    final isAux0 = isAux?.call() ?? media.isAux;
    final collectionId0 =
        collectionId != null ? collectionId() : media.collectionId!;
    final int collectionId1;
    final bool? isHidden0;
    if (collectionId0 == null) {
      collectionId1 =
          (isAux0 ? (await _notesCollection) : (await _defaultCollection)).id!;
      isHidden0 = true;
    } else {
      collectionId1 = collectionId0;
      isHidden0 = null;
    }
    final String fExt0;
    final String computedMD5String;
    final String defaultName;
    if (path != null) {
      // File changed
      computedMD5String = await File(path).checksum;
      final pathExt = p.extension(path);
      if (pathExt.replaceAll('.', '').isEmpty) {
        fExt0 = '.unk'; // FIXME: Use MIME to determine
      } else {
        fExt0 = fExt != null ? fExt() : p.extension(path);
      }
      defaultName = name != null
          ? name()
          : id == null
              ? media.name
              : p.basename(path);
    } else {
      computedMD5String = media.md5String!;
      fExt0 = media.fExt;
      defaultName = name != null ? name() : media.name;
    }

    final updated0 = media
        .updateContent(
          id: id,
          md5String: () => computedMD5String,
          name: () => defaultName,
          type: type == null ? null : () => type,
          collectionId: () => collectionId1,
          fExt: () => fExt0,
          isAux: () => isAux0,
          // Set defaults if not provided
          serverUID: () => serverUID != null ? serverUID() : media.serverUID,
          ref: ref,
          originalDate: originalDate,
          isDeleted: isDeleted,
          isEdited: isEdited,
          // clear pin if new path provided
        )
        .updateStatus(
          isHidden: () =>
              isHidden0 ?? (isHidden != null ? isHidden() : media.isHidden),
          isPreviewCached: () => isPreviewCached?.call() ?? false,
          isMediaCached: () => isMediaCached?.call() ?? false,
          isMediaOriginal: () => isMediaOriginal?.call() ?? false,
          previewLog: () => previewLog != null ? previewLog() : null,
          mediaLog: () => mediaLog != null ? mediaLog() : null,
          haveItOffline: () => haveItOffline?.call() ?? media.haveItOffline,
          mustDownloadOriginal: () =>
              mustDownloadOriginal?.call() ?? media.mustDownloadOriginal,
          pin: () => pin != null
              ? pin()
              : (path != null)
                  ? null
                  : media.pin,
        );

    return upsertMedia(
      updated0,
      parents: parents,
      path: path,
      originalMedia: media,
    );
  }

  Future<CLMedia?> upsertMedia(
    CLMedia media, {
    CLMedia? originalMedia,
    String? path,
    List<CLMedia>? parents,
    bool shouldRefresh = true,
  }) async {
    // Save Media
    final CLMedia updated0;
    if (path != null) {
      final currentMediaPath = directories.getMediaAbsolutePath(media);
      File(path).copySync(currentMediaPath);

      updated0 = await _generateMediaPreview(
        media: media.updateStatus(
          isMediaCached: () => true,
          isMediaOriginal: () => true,
        ),
      );
    } else {
      updated0 = media;
    }
    if (originalMedia == updated0) {
      return originalMedia;
    }

    // Update in DB
    final mediaFromDB = await store.upsertMedia(
      updated0,
      parents: parents,
    );
    log('store updated');
    if (shouldRefresh) {
      store.reloadStore();
    }
    return mediaFromDB;
  }

  Future<Collection> get _notesCollection async =>
      await store.reader.getCollectionByLabel('*** Notes') ??
      (await upsertCollection(
        const Collection(label: '*** Notes'),
      ));
  Future<Collection> get _defaultCollection async =>
      await store.reader.getCollectionByLabel(tempCollectionName) ??
      (await upsertCollection(
        Collection(label: tempCollectionName),
      ));

  Future<CLMedia> _generateMediaPreview({
    required CLMedia media,
    int dimension = 256,
  }) async {
    var updateMedia = media;
    try {
      final currentMediaPath = directories.getMediaAbsolutePath(media);
      final currentPreviewPath = directories.getPreviewAbsolutePath(media);
      final error = <String, String>{}; // Could use Completer ?

      final res = await generatePreview(
        inputFile: currentMediaPath,
        outputFile: currentPreviewPath,
        type: media.type,
        dimension: dimension,
        onError: (p0) {
          error[p0.key] = p0.value;
        },
      );
      if (res) {
        updateMedia = updateMedia.updateStatus(
          isPreviewCached: () => true,
          previewLog: () => null,
        );
      } else {
        if (error.isNotEmpty) {
          updateMedia = updateMedia.updateStatus(
            isPreviewCached: () => false,
            previewLog: () => jsonEncode(error),
          );
        }
      }
    } catch (e) {
      updateMedia = updateMedia.updateStatus(
        isPreviewCached: () => false,
        previewLog: () =>
            jsonEncode({'decodeError': 'Exception while generating preview'}),
      );
    }
    return updateMedia;
  }

  static Future<bool> generatePreview({
    required String inputFile,
    required String outputFile,
    required CLMediaType type,
    required void Function(MapEntry<String, String> entry) onError,
    int dimension = 256,
  }) async {
    switch (type) {
      case CLMediaType.image:
        final img.Image? inputImage;
        if (lookupMimeType(inputFile) == 'image/heic') {
          final jpegPath = await HeifConverter.convert(
            inputFile,
            output: '$inputFile.jpeg',
          );
          if (jpegPath == null) {
            onError(
              const MapEntry(
                'decodeError',
                'HeifConverter  Failed to convert HEIC file to JPEG',
              ),
            );
            inputImage = null;
          } else {
            inputImage = img.decodeJpg(File(jpegPath).readAsBytesSync());
            if (inputImage == null) {
              onError(
                const MapEntry(
                  'decodeError',
                  'Failed to decode jpeg image (converted from heic)',
                ),
              );
            }
          }
        } else {
          inputImage = img.decodeImage(File(inputFile).readAsBytesSync());
          if (inputImage == null) {
            onError(const MapEntry('decodeError', 'Failed to decode Image'));
          }
        }
        if (inputImage == null) return false;

        final int thumbnailHeight;
        final int thumbnailWidth;
        if (inputImage.height > inputImage.width) {
          thumbnailHeight = dimension;
          thumbnailWidth =
              (thumbnailHeight * inputImage.width) ~/ inputImage.height;
        } else {
          thumbnailWidth = dimension;
          thumbnailHeight =
              (thumbnailWidth * inputImage.height) ~/ inputImage.width;
        }
        final thumbnail = img.copyResize(
          inputImage,
          width: thumbnailWidth,
          height: thumbnailHeight,
        );
        File(outputFile).writeAsBytesSync(
          Uint8List.fromList(img.encodeJpg(thumbnail)),
        );
        return true;

      case CLMediaType.video:
        await File(outputFile).deleteIfExists();
        try {
          final double frameCount;
          final probleSession =
              await FFprobeKit.execute('-v error -select_streams v:0 '
                  '-show_entries stream=r_frame_rate,duration '
                  '-of default=nokey=1:noprint_wrappers=1 "$inputFile"');
          final probeReturnCode = await probleSession.getReturnCode();
          final output = await probleSession.getOutput();
          if ((probeReturnCode?.isValueSuccess() ?? false) && output != null) {
            final result = LineSplitter.split(output).toList();
            final frameRateFraction = result[0];
            final duration = double.parse(result[1]);

            final fpsSplit = frameRateFraction.split('/');
            final fps = double.parse(fpsSplit[0]) / double.parse(fpsSplit[1]);

            frameCount = fps * duration;
          } else {
            final log = await probleSession.getAllLogsAsString();

            onError(
              MapEntry(
                  'decodeError',
                  'FFprobeKit return code: $probeReturnCode. '
                      'Details: $log}'),
            );

            return false;
          }
          final tileSize = computeTileSize(frameCount);
          final frameFreq = (frameCount / (tileSize * tileSize)).floor();

          final session = await FFmpegKit.execute(
            '-loglevel panic -y '
            '-i "$inputFile" '
            '-frames 1 -q:v 1 '
            '-vf "select=not(mod(n\\,$frameFreq)),scale=-1:$dimension,tile=${tileSize}x$tileSize" '
            '"$outputFile"',
          );
          final returnCode = await session.getReturnCode();
          if (!ReturnCode.isSuccess(returnCode)) {
            await File(outputFile).deleteIfExists();
            final log = await session.getAllLogsAsString();
            onError(MapEntry('previewError', 'FFmpegKit:$log'));
          }

          return ReturnCode.isSuccess(returnCode);
        } catch (e) {
          await File(outputFile).deleteIfExists();
          onError(MapEntry('previewError', 'FFmpegKit crashed $e'));
          return false;
        }

      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        onError(
          const MapEntry(
            'decodeError',
            "Unsupported Media Type. Preview can't be generated",
          ),
        );
        return false;
    }
  }

  static int computeTileSize(double frameCount) {
    if (frameCount >= 16) {
      return 4;
    } else if (frameCount >= 9) {
      return 3;
    } else {
      return 2;
    }
  }

  Future<CLMedia> replaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    return (await updateMedia(
          media,
          path: path,
          isEdited: true,
        )) ??
        media;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    return (await updateMedia(
          media,
          path: path,
          id: () => null,
          serverUID: () => null, // Creating new media locally
          isEdited: false, // Creating new Media locally
        )) ??
        media;
  }

  Stream<Progress> moveToCollectionStream({
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  }) async* {
    final Collection updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      final withId = await store.reader.getCollectionByLabel(collection.label);
      updatedCollection = await upsertCollection(withId ?? collection);
    } else {
      updatedCollection = collection;
    }
    yield Progress(
      fractCompleted: 0,
      currentItem: 'moving to collection : ${updatedCollection.label}',
    );

    if (media.isNotEmpty) {
      final updatedList = <CLMedia>[];

      for (final (i, m) in media.indexed) {
        final updated = await updateMedia(
          m,
          isHidden: () => false,
          collectionId: () => updatedCollection.id!,
          isEdited: true,
        );
        if (updated != null) {
          updatedList.add(updated);
        }

        yield Progress(
          fractCompleted: i / media.length,
          currentItem: m.name,
        );
        await Future<void>.delayed(const Duration(microseconds: 10));
      }
      store.reloadStore();
      await onDone?.call(mediaMultiple: updatedList);
    }
  }

  static Future<CLMediaBase> tryDownloadMedia(
    CLMediaBase mediaFile, {
    required CLDirectories deviceDirectories,
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
      //CLMediaType.audio,
      CLMediaType.file,
    ].contains(mimeType)) {
      return mediaFile;
    }
    final downloadedFile = await URLHandler.download(
      mediaFile.name,
      deviceDirectories.download.path,
    );
    if (downloadedFile == null) {
      return mediaFile;
    }
    return mediaFile.copyWith(
      name: () => downloadedFile,
      type: () => mimeType!,
    );
  }

  static Future<CLMediaBase> identifyMediaType(
    CLMediaBase mediaFile, {
    required CLDirectories deviceDirectories,
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
    return mediaFile.copyWith(type: () => mimeType);
  }

  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> existingItems,
      required List<CLMedia> newItems,
    }) onDone,
  }) async* {
    final existingItems = <CLMedia>[];
    final newItems = <CLMedia>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: p.basename(mediaFiles[0].name),
      fractCompleted: 0,
    );
    for (final (i, item0) in mediaFiles.indexed) {
      final item1 = await tryDownloadMedia(
        item0,
        deviceDirectories: directories,
      );
      final item = await identifyMediaType(
        item1,
        deviceDirectories: directories,
      );
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(item.name);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await store.reader.getMediaByMD5String(md5String);
          if (duplicate != null) {
            // multiple duplicate may be imported together
            if (existingItems.where((e) => e.id == duplicate.id!).firstOrNull ==
                null) {
              existingItems.add(duplicate);
            }
          } else {
            // avoid recomputing md5
            final newItem = await newMedia(item.name, type: item.type);
            if (newItem != null) {
              newItems.add(newItem);
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
            : p.basename(
                mediaFiles[i + 1].name,
              ),
        fractCompleted: (i + 1) / mediaFiles.length,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    store.reloadStore();
    onDone(
      existingItems: existingItems.where((e) => e.mediaLog == null).toList(),
      newItems: newItems.where((e) => e.mediaLog == null).toList(),
    );
  }

  // This should not be in this way.
  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  ) {
    // For now, lets only focus on locally cached.
    // FIXME: If the media is from server, we need to find a way
    // to download and share
    final files = media
        .map(directories.getMediaAbsolutePath)
        .where((e) => File(e).existsSync());
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      files.toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }
}
