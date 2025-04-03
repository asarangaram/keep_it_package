import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:content_store/content_store.dart';
import 'package:content_store/extensions/ext_cl_media.dart';
import 'package:content_store/extensions/ext_cldirectories.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:keep_it_state/keep_it_state.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';

import 'gallery_pin.dart';
import 'share_files.dart';

import 'url_handler.dart';

class MediaUpdater {
  MediaUpdater({
    required this.store,
    required this.directories,
    required this.albumManager,
    required this.getCollectionByLabel,
    required this.tempCollectionName,
  });
  Store store;
  CLDirectories directories;
  final AlbumManager albumManager;
  final Future<CLEntity> Function(
    String label, {
    DateTime? createdDate,
    DateTime? updatedDate,
    bool shouldRefresh,
    bool restoreIfNeeded,
  }) getCollectionByLabel;
  final String tempCollectionName;

  /// Method: upsert
  Future<CLEntity?> upsert(
    CLEntity media0, {
    bool shouldRefresh = true,
    String? path,
  }) async {
    final CLEntity? media;
    if (path != null) {
      final currentMediaPath = directories.getMediaAbsolutePath(media0);
      if (currentMediaPath != path) {
        File(path).copySync(currentMediaPath);
      }

      media = await _generateMediaPreview(
        media: media0.updateStatus(),
      );
    } else {
      /* final currentMediaPath = directories.getMediaAbsolutePath(media0);
      final currentPreviewPath = directories.getPreviewAbsolutePath(media0);
      final isMediaCached = File(currentMediaPath).existsSync();
      final isPreviewCached = File(currentPreviewPath).existsSync();
      media = media0.updateStatus(
        isMediaCached: () => isMediaCached,
        isPreviewCached: () => isPreviewCached,
      ); */
      media = media0;
    }

    if (media == null) return null;

    CLEntity? c;
    if (media.id != null) {
      c = await store.reader.getEntity(id: media.id);
    }
    if (c == null && media.md5 != null) {
      c ??= await store.reader.getEntity(md5: media.md5);
    }

    if (c != null) {
      if (media.id != null && media.id != c.id) {
        throw Exception('Conflict in id');
      }
    }

    final mediaFromDB = await store.upsertMedia(
      (media.id != null)
          ? media
          : media.clone(
              id: () => c?.id,
            ),
    );
    if (shouldRefresh) {
      store.reloadStore();
    }
    return mediaFromDB;
  }

  /// Method: delete
  Future<bool> delete(
    int id, {
    bool shouldRefresh = true,
  }) async {
    final m = await store.reader.getEntity(id: id);
    if (m != null) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: true,
        ),
      );
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  // Method: deletePermanently
  Future<bool> deletePermanently(
    int id, {
    bool shouldRefresh = true,
  }) {
    return deletePermanentlyMultiple({id}, shouldRefresh: shouldRefresh);
  }

  Future<bool> deletePermanentlyMultiple(
    Set<int> ids2Delete, {
    bool shouldRefresh = true,
  }) async {
    final mediaMultiple =
        await store.reader.getEntitiesByIdList(ids2Delete.toList());

    // Gather Notes

    if (mediaMultiple.isNotEmpty) {
      for (final m in mediaMultiple) {
        await store.deleteMedia(m);
        await File(directories.getMediaAbsolutePath(m)).deleteIfExists();
        await File(directories.getPreviewAbsolutePath(m)).deleteIfExists();
      }
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  /// Method: deleteMultiple
  Future<bool> deleteMultiple(
    Set<int> ids2Delete, {
    bool shouldRefresh = true,
  }) async {
    final mediaMultiple =
        await store.reader.getEntitiesByIdList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: true,
        ),
      );
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  Future<bool> restore(
    int id, {
    bool shouldRefresh = true,
  }) async {
    throw UnimplementedError();
  }

  // Method: restoreMultiple
  Future<bool> restoreMultiple(
    Set<int> ids2Delete, {
    bool shouldRefresh = true,
  }) async {
    final mediaMultiple =
        await store.reader.getEntitiesByIdList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: false,
        ),
      );
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  Future<bool> pinToggleMultiple(
    Set<int?> ids2Delete, {
    required String? Function(CLEntity media) onGetPath,
    bool shouldRefresh = true,
  }) async {
    final media =
        await store.reader.getEntitiesByIdList(ids2Delete.nonNullableList);
    final bool res;
    if (media.any((e) => e.pin == null)) {
      res = await pinCreateMultiple(media, onGetPath: onGetPath);
    } else {
      res = await pinRemoveMultiple(media);
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return res;
  }

  Future<bool> pinRemoveMultiple(
    List<CLEntity> mediaMultiple, {
    bool shouldRefresh = true,
  }) async {
    final pinnedMedia = mediaMultiple.where((e) => e.pin != null).toList();
    final res = await albumManager.removeMultipleMedia(
      pinnedMedia.map((e) => e.pin!).toList(),
    );
    if (res) {
      for (final m in pinnedMedia) {
        await store.upsertMedia(m.updateStatus(pin: () => null));
      }
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return res;
  }

  Future<bool> pinCreateMultiple(
    List<CLEntity> mediaMultiple, {
    required String? Function(CLEntity media) onGetPath,
    bool shouldRefresh = true,
  }) async {
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLEntity>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final path = onGetPath(media);
        if (path != null) {
          final pin = await albumManager.addMedia(
            path,
            title: media.label ?? 'unnamed',
            isImage: media.mediaType == CLMediaType.image,
            isVideo: media.mediaType == CLMediaType.video,
            desc: 'KeepIT',
          );
          if (pin != null) {
            updatedMedia.add(media.updateStatus(pin: () => pin));
          }
        }
      }
    }
    for (final m in updatedMedia) {
      await store.upsertMedia(m);
    }
    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  Future<CLEntity?> create(
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
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isAux,
    /* ValueGetter<int?>? id, */
  }) async {
    final defaultName = name != null ? name() : p.basename(path);
    final computedMD5String = await File(path).checksum;

    final collectionId0 = parentId != null ? parentId() : null;
    final int collectionId1;
    final bool? isHidden0;
    final metadata = switch (type) {
      CLMediaType.image => await File(path).getImageMetaData(),
      CLMediaType.video => await File(path).getVideoMetaData(),
      _ => null
    };
    final originalDate0 =
        originalDate ?? (metadata == null ? null : () => metadata.originalDate);
    if (originalDate0 != null) {
      log('originalDate is set as ${originalDate0()}');
    }
    if (collectionId0 == null) {
      collectionId1 = (await _defaultCollection).id!;

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

    final updated0 = CLEntity.media(
      md5: computedMD5String,
      label: defaultName,
      type: type.name,
      fileSize: 0,
      mimeType: 'TODO',
      parentId: collectionId1,
      isHidden: isHidden0 ?? isHidden?.call() ?? false,
      extension: fExt0,
      description: ref != null ? ref() : null,
      createDate: originalDate0 != null ? originalDate0() : null,
      isDeleted: isDeleted?.call() ?? false,
      pin: pin != null ? pin() : null,
    );
    return upsert(
      updated0,
      path: path,
    );
  }

  Future<CLEntity?> update(
    CLEntity media, {
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
    ValueGetter<bool>? isDeleted,
    ValueGetter<bool>? isHidden,
    ValueGetter<String?>? pin,
    ValueGetter<int?>? parentId,
    ValueGetter<bool>? isAux,
    ValueGetter<int?>? id, // id is overwritten only to clone

    bool shouldRefresh = true,
  }) async {
    if (media.pin != null && path == null) {
      throw Exception('Remove pin before updating media');
    }
    if (id != null && id() != null) {
      throw Exception('id can only be cleared');
    }

    final collectionId0 = parentId != null ? parentId() : media.parentId!;
    final int collectionId1;
    final bool? isHidden0;
    if (collectionId0 == null) {
      collectionId1 = (await _defaultCollection).id!;
      isHidden0 = true;
    } else {
      collectionId1 = collectionId0;
      isHidden0 = null;
    }
    final String fExt0;
    final String computedMD5String;
    final String? defaultName;
    final ValueGetter<DateTime?>? originalDate0;
    if (path != null) {
      // File changed
      computedMD5String = await File(path).checksum;
      final pathExt = p.extension(path);
      if (pathExt.replaceAll('.', '').isEmpty) {
        final mime = lookupMimeType(path);
        if (mime == null) {
          fExt0 = '.unk';
        } else {
          fExt0 = extensionFromMime(mime) ?? '.unk';
        }
      } else {
        fExt0 = fExt != null ? fExt() : p.extension(path);
      }
      defaultName = name != null
          ? name()
          : id == null
              ? media.label
              : p.basename(path);
      final metadata = switch (media.mediaType) {
        CLMediaType.image => await File(path).getImageMetaData(),
        CLMediaType.video => await File(path).getVideoMetaData(),
        _ => null
      };
      originalDate0 = originalDate ??
          (metadata == null ? null : () => metadata.originalDate);
    } else {
      computedMD5String = media.md5!;
      fExt0 = media.extension!;
      defaultName = name != null ? name() : media.label;
      originalDate0 = originalDate;
    }
    if (originalDate0 != null) {
      log('originalDate is set as ${originalDate0()}');
    }

    final updated0 = media
        .updateContent(
          md5: () => computedMD5String,
          label: () => defaultName,
          type: type == null ? null : () => type.name,
          parentId: () => collectionId1,
          extension: () => fExt0,

          // Set defaults if not provided
          description: ref,
          createDate: originalDate0,
          isDeleted: isDeleted?.call(),

          // clear pin if new path provided
        )
        .updateStatus(
          isHidden: () =>
              isHidden0 ?? (isHidden != null ? isHidden() : media.isHidden),
          pin: () => (pin != null
              ? pin()
              : (path != null)
                  ? null
                  : media.pin),
        );

    return upsert(
      updated0,
      path: path,
      shouldRefresh: shouldRefresh,
    );
  }

  Future<CLEntity> get _defaultCollection async =>
      getCollectionByLabel(tempCollectionName, restoreIfNeeded: true);

  Future<CLEntity?> _generateMediaPreview({
    required CLEntity media,
    int dimension = 256,
  }) async {
    final updateMedia = media;
    try {
      final currentMediaPath = directories.getMediaAbsolutePath(media);
      final currentPreviewPath = directories.getPreviewAbsolutePath(media);

      await generatePreview(
        inputFile: currentMediaPath,
        outputFile: currentPreviewPath,
        type: media.mediaType,
        dimension: dimension,
      );

      return updateMedia;
    } catch (e) {
      return null;
    }
  }

  static Future<String?> generatePreview({
    required String inputFile,
    required String outputFile,
    required CLMediaType type,
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
            return 'decodeError: '
                'HeifConverter  Failed to convert HEIC file to JPEG';
          } else {
            inputImage = img.decodeJpg(File(jpegPath).readAsBytesSync());
            if (inputImage == null) {
              return 'decodeError: '
                  'Failed to decode jpeg image (converted from heic)';
            }
          }
        } else {
          inputImage = img.decodeImage(File(inputFile).readAsBytesSync());
          if (inputImage == null) {
            return 'decodeError: ' 'Failed to decode Image';
          }
        }

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
        return null;

      case CLMediaType.video:
      /* await File(outputFile).deleteIfExists();
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

            return 'decodeError: FFprobeKit return code: $probeReturnCode. '
                'Details: $log}';
          }
          final tileSize = _computeTileSize(frameCount);
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
            return 'previewError: FFmpegKit:$log';
          }

          return null;
        } catch (e) {
          await File(outputFile).deleteIfExists();
          return 'previewError: FFmpegKit crashed $e';
        } */

      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        return 'decodeError: '
            "Unsupported Media Type. Preview can't be generated";
    }
  }

  /* static int _computeTileSize(double frameCount) {
    if (frameCount >= 16) {
      return 4;
    } else if (frameCount >= 9) {
      return 3;
    } else {
      return 2;
    }
  } */

  Future<CLEntity> replaceContent(
    String path, {
    required CLEntity media,
  }) async {
    return (await update(
          media,
          path: path,
          isEdited: true,
        )) ??
        media;
  }

  Future<CLEntity> updateCloneAndReplaceContent(
    String path, {
    required CLEntity media,
  }) async {
    return (await create(
          path,
          type: media.mediaType,
          fExt: () => media.extension!,
          originalDate: () => media.createDate,
          parentId: () => media.parentId,
        )) ??
        media;
  }

  Stream<Progress> moveMultiple({
    required List<CLEntity> media,
    required CLEntity collection,
    Future<void> Function({required List<CLEntity> mediaMultiple})? onDone,
    bool shouldRefresh = true,
  }) async* {
    final CLEntity updatedCollection;
    if (collection.id == null) {
      yield const Progress(
        fractCompleted: 0,
        currentItem: 'Creating new collection',
      );
      updatedCollection = await getCollectionByLabel(
        collection.label!,
        createdDate: collection.addedDate,
        updatedDate: collection.updatedDate,
        shouldRefresh: false,
        restoreIfNeeded: true,
      );
    } else {
      updatedCollection = collection;
    }
    yield Progress(
      fractCompleted: 0,
      currentItem: 'moving to collection : ${updatedCollection.label}',
    );

    if (media.isNotEmpty) {
      final updatedList = <CLEntity>[];

      for (final (i, m) in media.indexed) {
        final updated = await update(
          m,
          isHidden: () => false,
          parentId: () => updatedCollection.id,
          isEdited: true,
          shouldRefresh: false,
        );
        if (updated != null) {
          updatedList.add(updated);
        }

        yield Progress(
          fractCompleted: i / media.length,
          currentItem: m.label ?? 'unnamed',
        );
        await Future<void>.delayed(const Duration(milliseconds: 1000));
      }
      if (shouldRefresh) {
        store.reloadStore();
      }
      await onDone?.call(mediaMultiple: updatedList);
    }
  }

  static Future<CLMediaCandidate> _tryDownloadMedia(
    CLMediaCandidate mediaFile, {
    required CLDirectories deviceDirectories,
  }) async {
    if (mediaFile.type != CLMediaType.url) {
      return mediaFile;
    }
    final mimeType = await URLHandler.getMimeType(
      mediaFile.path,
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
      mediaFile.path,
      deviceDirectories.download.path,
    );
    if (downloadedFile == null) {
      return mediaFile;
    }
    return mediaFile.copyWith(
      path: () => downloadedFile,
      type: () => mimeType!,
    );
  }

  static Future<CLMediaCandidate> _identifyType(
    CLMediaCandidate mediaFile, {
    required CLDirectories deviceDirectories,
  }) async {
    if (mediaFile.type != CLMediaType.file) {
      return mediaFile;
    }

    final mimeType = switch (lookupMimeType(mediaFile.path)) {
      (final String mime) when mime.startsWith('image') => CLMediaType.image,
      (final String mime) when mime.startsWith('video') => CLMediaType.video,
      _ => CLMediaType.file
    };
    if (mimeType == CLMediaType.file) {
      return mediaFile;
    }
    return mediaFile.copyWith(type: () => mimeType);
  }

  Stream<Progress> analyseMultiple({
    required List<CLMediaCandidate> mediaFiles,
    required void Function({
      required List<CLEntity> existingItems,
      required List<CLEntity> newItems,
    }) onDone,
    bool shouldRefresh = true,
  }) async* {
    final existingItems = <CLEntity>[];
    final newItems = <CLEntity>[];
    //await Future<void>.delayed(const Duration(seconds: 3));
    yield Progress(
      currentItem: p.basename(mediaFiles[0].path),
      fractCompleted: 0,
    );
    for (final (i, item0) in mediaFiles.indexed) {
      final item1 = await _tryDownloadMedia(
        item0,
        deviceDirectories: directories,
      );
      final item = await _identifyType(
        item1,
        deviceDirectories: directories,
      );
      if ([CLMediaType.image, CLMediaType.video].contains(item.type)) {
        final file = File(item.path);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = await store.reader.getEntity(md5: md5String);
          if (duplicate != null) {
            // multiple duplicate may be imported together
            if (existingItems.where((e) => e.id == duplicate.id!).firstOrNull ==
                null) {
              existingItems.add(duplicate);
            }
          } else {
            // avoid recomputing md5
            final newItem = await create(item.path, type: item.type);
            if (newItem != null) {
              newItems.add(newItem);
            }
          }
        } else {
          /* Missing file? ignoring */
        }
      } else {
        // Skip for now
      }

      await Future<void>.delayed(const Duration(milliseconds: 1));

      yield Progress(
        currentItem: (i + 1 == mediaFiles.length)
            ? ''
            : p.basename(
                mediaFiles[i + 1].path,
              ),
        fractCompleted: (i + 1) / mediaFiles.length,
      );
    }

    await Future<void>.delayed(const Duration(milliseconds: 1));
    if (shouldRefresh) {
      store.reloadStore();
    }
    onDone(
      existingItems: existingItems,
      newItems: newItems,
    );
  }

  // This should not be in this way.
  Future<bool?> share(
    BuildContext context,
    List<CLEntity> media,
  ) {
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

  String fileRelativePath(CLEntity media) => p.join(
        directories.media.relativePath,
        media.mediaFileName,
      );
  String previewRelativePath(CLEntity media) => p.join(
        directories.thumbnail.relativePath,
        media.previewFileName,
      );

  String fileAbsolutePath(CLEntity media) => p.join(
        directories.media.pathString,
        media.mediaFileName,
      );
  String previewAbsolutePath(CLEntity media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );
}
