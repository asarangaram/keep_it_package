import 'dart:convert';
import 'dart:io';
import 'dart:nativewrappers/_internal/vm/lib/ffi_allocation_patch.dart';
import 'dart:typed_data';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/src/extensions/ext_cl_media.dart';
import 'package:content_store/src/storage_service/models/file_system/models/cl_directories.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import 'gallery_pin.dart';

extension GalleryMapExt on CLMedias {
  List<GalleryGroup<CLMedia>> get galleryMap => [];
  bool get isNotEmpty => entries.isNotEmpty;
  bool get isEmpty => entries.isEmpty;
}

abstract class DBReader {}

class StoreUpdater {
  StoreUpdater(this.store, this.directories)
      : tempCollectionName = '*** Recently Captured',
        albumManager = AlbumManager(albumName: 'KeepIt');
  final Store store;
  final CLDirectories directories;

  final AlbumManager albumManager;

  final String tempCollectionName;

  //// Read APIs

  /*  Collection? getCollectionById(int? id);

  CLMedias getStaleMedia();
  CLMedias getPinnedMedia();
  CLMedias getDeletedMedia();
  CLMedias getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  });
  CLMedia? getMediaById(int? id);
  CLMedias getMediaMultipleByIds(List<int> idList);
  int getMediaCountByCollectionId(int? collectionId); */

  String getPreviewAbsolutePath(CLMedia media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );

  String getMediaAbsolutePath(CLMedia media) => p.join(
        directories.media.path.path,
        media.mediaFileName,
      );

  Future<bool> deleteCollectionById(int id) async {
    final mediaMultiple = await store.reader.getMediaByCollectionId(id);

    for (final m in mediaMultiple) {
      await store.upsertMedia(m.copyWith(isDeleted: true));
    }
    return true;
  }

  Future<bool> deleteMediaById(int id) async {
    final m = await store.reader.getMediaById(id);
    if (m != null) {
      await store.upsertMedia(m.copyWith(isDeleted: true));
    }
    return true;
  }

  Future<bool> deleteMediaMultipleById(Set<int> ids2Delete) async {
    final mediaMultiple =
        await store.reader.getMediasByIDList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(m.copyWith(isDeleted: true));
    }
    return true;
  }

  Future<bool> restoreMediaMultipleById(Set<int> ids2Delete) async {
    final mediaMultiple =
        await store.reader.getMediasByIDList(ids2Delete.toList());
    for (final m in mediaMultiple) {
      await store.upsertMedia(m.copyWith(isDeleted: false));
    }
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
        await File(getMediaAbsolutePath(m)).deleteIfExists();
        await File(getPreviewAbsolutePath(m)).deleteIfExists();
      }
    }

    return true;
  }

  Future<bool> togglePinById(int id) {
    throw UnimplementedError();
  }

  Future<bool> togglePinMultipleById(Set<int?> ids2Delete) {
    throw UnimplementedError();
  }

  Future<bool> togglePinMultiple(
    List<CLMedia> media,
  ) async {
    if (media.any((e) => e.pin == null)) {
      return pinMediaMultiple(media);
    } else {
      return removePinMediaMultiple(media);
    }
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
        await store.upsertMedia(m.removePin());
      }
    }
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
          updatedMedia.add(media.copyWith(pin: pin));
        }
      }
    }
    for (final m in updatedMedia) {
      await store.upsertMedia(m);
    }

    return true;
  }

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);

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

    return updated;
  }

  Future<CLMedia?> newMedia(
    String path,
    CLMediaType type, {
    bool? isAux,
    String? ref,
    DateTime? originalDate,
    DateTime? createdDate,
    DateTime? updatedDate,
    String? md5String,
    bool? isDeleted,
    bool? isHidden,
    String? pin,
    int? collectionId,
    bool? isPreviewCached,
    bool? isMediaCached,
    String? previewLog,
    String? mediaLog,
    bool? isMediaOriginal,
    int? serverUID,
    bool? isEdited,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    List<CLMedia>? parents,
  }) async {
    return null;

    /*  return upsertMedia(
      path,
      type,
      isAux: isAux,
      ref: ref,
      originalDate: originalDate,
      createdDate: createdDate,
      updatedDate: updatedDate,
      md5String: md5String,
      isDeleted: isDeleted,
      isHidden: isHidden,
      pin: pin,
      collectionId: collectionId,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      previewLog: previewLog,
      mediaLog: mediaLog,
      isMediaOriginal: isMediaOriginal,
      serverUID: serverUID,
      isEdited: isEdited,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
      parents: parents,
      id: null,
    ); */
  }

  Future<CLMedia?> updateMedia(
    CLMedia media,
    String path,
    CLMediaType type, {
    required ValueGetter<bool?>? isAux,
    required ValueGetter<String?>? ref_111,
    required ValueGetter<DateTime?>? originalDate_111,
    required ValueGetter<DateTime?>? createdDate_111,
    required ValueGetter<DateTime?>? updatedDate_111,
    required ValueGetter<String?>? md5String_111,
    required ValueGetter<bool?>? isDeleted_111,
    required ValueGetter<bool?>? isHidden_111,
    required ValueGetter<String?>? pin_111,
    required ValueGetter<int?>? collectionId_111,
    required ValueGetter<bool?>? isPreviewCached_111,
    required ValueGetter<bool?>? isMediaCached_111,
    required ValueGetter<String?>? previewLog_111,
    required ValueGetter<String?>? mediaLog_111,
    required ValueGetter<bool?>? isMediaOriginal_111,
    required ValueGetter<int?>? serverUID_111,
    required ValueGetter<bool?>? isEdited_111,
    required ValueGetter<bool?>? haveItOffline_111,
    required ValueGetter<bool?>? mustDownloadOriginal_111,
    required ValueGetter<List<CLMedia>?>? parents_111,
    required ValueGetter<int?>? id_111,
  }) async {
    return null;
  }

  Future<Collection> get notesCollection async =>
      await store.reader.getCollectionByLabel('*** Notes') ??
      (await upsertCollection(
        const Collection(label: '*** Notes'),
      ));
  Future<Collection> get defaultCollection async =>
      await store.reader.getCollectionByLabel(tempCollectionName) ??
      (await upsertCollection(
        Collection(label: tempCollectionName),
      ));

  /*  Future<CLMedia?> upsertMedia({
    required String path,
    required CLMediaType type,
    required bool? isAux,
    required String? ref,
    required DateTime? originalDate,
    required DateTime? createdDate,
    required DateTime? updatedDate,
    required String? md5String,
    required bool? isDeleted,
    required bool? isHidden,
    required String? pin,
    required int? collectionId,
    required bool? isPreviewCached,
    required bool? isMediaCached,
    required String? previewLog,
    required String? mediaLog,
    required bool? isMediaOriginal,
    required int? serverUID,
    required bool? isEdited,
    required bool? haveItOffline,
    required bool? mustDownloadOriginal,
    required List<CLMedia>? parents,
    required int? id,
  }) async {
    final md5String0 = md5String ?? await File(path).checksum;
    final isAux0 = isAux ?? false;
    final collectionId0 = collectionId ??
        (isAux0.call() ? (await notesCollection) : (await defaultCollection))
            .id!;
    final savedMedia = CLMedia(
      /// These parameter are reset when a new content is provided
      id: id,
      name: p.basename(path),
      fExt: p.extension(path),
      type: type,
      md5String: md5String0,
      isPreviewCached: false,
      isMediaCached: false,
      previewLog: null,
      mediaLog: null,
      isMediaOriginal: true,

      /// Unless overridden, these parameters will be taken from media, if not,
      /// a default value is provided
      collectionId: collectionId0,
      isHidden: collectionId0 == (await defaultCollection).id!,
      isDeleted: isDeleted ?? false,
      isAux: isAux0,

      isEdited: isEdited ?? false,
      serverUID: serverUID,
      haveItOffline: haveItOffline ?? true,
      mustDownloadOriginal: mustDownloadOriginal ?? false,
    );

    final mediaFromDB = await store.upsertMedia(
      savedMedia.copyWith(isMediaCached: true, isMediaOriginal: true),
      parents: parents,
    );
    if (mediaFromDB != null) {
      final currentMediaPath = getMediaAbsolutePath(mediaFromDB);
      File(path).copySync(currentMediaPath);
      return generateMediaPreview(media: mediaFromDB);
    }
    return null;
  } */

  Future<CLMedia> generateMediaPreview({
    required CLMedia media,
    int dimension = 256,
  }) async {
    var updateMedia = media;
    try {
      final currentMediaPath = getMediaAbsolutePath(media);
      final currentPreviewPath = getPreviewAbsolutePath(media);
      final error = <String, String>{};

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
        updateMedia = updateMedia.copyWith(
          isPreviewCached: true,
          isMediaCached: true,
        );
      } else {
        if (error.isNotEmpty) {
          updateMedia = updateMedia.copyWith(
            mediaLog: jsonEncode(error),
          );
        }
      }
    } catch (e) {
      updateMedia = updateMedia.copyWith(
        mediaLog:
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
  }) {
    throw UnimplementedError();
  }

  Future<CLMedia> cloneAndReplaceMedia(
    String path, {
    required CLMedia media,
  }) {
    throw UnimplementedError();
  }

  Stream<Progress> moveToCollectionStream({
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  }) {
    throw UnimplementedError();
  }

  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> existingItems,
      required List<CLMedia> newItems,
    }) onDone,
  }) {
    throw UnimplementedError();
  }

  // This should not be in this way.
  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  ) {
    throw UnimplementedError();
  }

  void onRefresh() {}
}
