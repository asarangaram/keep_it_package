// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:typed_data';

import 'package:colan_services/internal/extensions/ext_store.dart';
import 'package:colan_services/services/colan_service/models/cl_server.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../internal/extensions/ext_cl_media.dart';
import '../../../internal/extensions/list.dart';
import '../../gallery_service/models/m5_gallery_pin.dart';
import '../../sharing_service/models/share_files.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import 'url_handler.dart';

@immutable
class StoreCache {
  StoreCache({
    required this.collectionList,
    required this.mediaList,
    required this.directories,
    required this.server,
    required this.store,
    this.allowOnlineViewIfNotDownloaded = false,
  })  : tempCollectionName = '*** Recently Captured',
        albumManager = AlbumManager(albumName: 'KeepIt');

  final List<Collection> collectionList;
  final List<CLMedia> mediaList;
  final CLDirectories directories;
  final CLServer? server;
  final Store store;
  final bool allowOnlineViewIfNotDownloaded;
  final AlbumManager albumManager;

  final String tempCollectionName;

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Store Cache',
    );
  }

  Iterable<Collection> get validCollection =>
      collectionList; //.where((e) => !e.label.startsWith('***'));

  Iterable<CLMedia> get validMedia {
    final iterable =
        mediaList.where((e) => !(e.isDeleted ?? false) && e.mediaLog == null);

    return iterable.where(
      (e) =>
          e.isPreviewLocallyAvailable ||
          (e.isPreviewWaitingForDownload && server != null),
    );
  }

  bool hasMediaFile(CLMedia e) {
    return e.isMediaLocallyAvailable || (!e.haveItOffline && server != null);
  }

  List<Collection> getCollections({bool excludeEmpty = true}) {
    final Iterable<Collection> iterable;
    if (excludeEmpty) {
      iterable = validCollection.where(
        (c) => validMedia
            .where((e) => !(e.isHidden ?? false))
            .any((e) => e.collectionId == c.id),
      );
    } else {
      iterable = validCollection;
    }

    return iterable.toList();
  }

  Collection? getCollectionById(int? id) {
    if (id == null) return null;
    return collectionList.where((e) => e.id == id).firstOrNull;
  }

  Collection? getCollectionByLabel(String label) {
    return collectionList.where((e) => e.label == label).firstOrNull;
  }

  List<CLMedia> getStaleMedia() {
    return validMedia.where((e) => e.isHidden ?? false).toList();
  }

  List<CLMedia> getPinnedMedia() {
    return validMedia.where((e) => e.pin != null).toList();
  }

  List<CLMedia> getDeletedMedia() {
    return mediaList.where((e) => e.isDeleted ?? false).toList();
  }

  List<CLMedia> getCorrupetedMedia() {
    return mediaList.where((e) => e.isDeleted ?? false).toList();
  }

  CLMedia? getMediaById(int? id) {
    if (id == null) return null;
    return mediaList.where((e) => e.id == id).firstOrNull;
  }

  int? getMediaIndexById(int? id) {
    if (id == null) return null;
    return mediaList.indexWhere((e) => e.id == id);
  }

  CLMedia? getMediaByMD5(String md5String) {
    return mediaList.where((e) => e.md5String == md5String).firstOrNull;
  }

  CLMedia? getMediaByServerUID(int serverUID) {
    return mediaList.where((e) => e.serverUID == serverUID).firstOrNull;
  }

  List<CLMedia> getMediaMultipleByIds(List<int> idList) {
    return mediaList.where((e) => idList.contains(e.id)).toList();
  }

  int getMediaCountByCollectionId(int? collectionId) {
    return validMedia
        .where((e) => e.collectionId == collectionId && !(e.isHidden ?? false))
        .length;
  }

  List<CLMedia> getMediaByCollectionId(
    int? collectionId, {
    int maxCount = 0,
    bool isRandom = false,
  }) {
    if (collectionId == null) return [];

    final media = validMedia
        .where((e) => e.collectionId == collectionId && !(e.isHidden ?? false))
        .toList();

    if (maxCount > 0) {
      if (isRandom) {
        return media.pickRandomItems(maxCount);
      }
      return media.firstNItems(maxCount);
    }

    return media;
  }

  String getText(CLMedia? media) {
    if (media?.type != CLMediaType.text) return '';
    final uri = getMediaUri(media!);
    if (uri.scheme == 'file') {
      final path = uri.toFilePath();

      return File(path).existsSync()
          ? File(path).readAsStringSync()
          : 'Content Missing. File not found';
    }
    throw UnimplementedError('Implement for Server');
  }

  Uri getPreviewUri(CLMedia media) {
    return Uri.file(getPreviewAbsolutePath(media));
  }

  AsyncValue<Uri> getPreviewUriAsync(CLMedia media) {
    final flag = allowOnlineViewIfNotDownloaded;

    try {
      return switch (media) {
        (final CLMedia m) when media.isPreviewLocallyAvailable =>
          AsyncValue.data(Uri.file(getPreviewAbsolutePath(m))),
        (final CLMedia m) when media.isPreviewDownloadFailed =>
          throw Exception(m.previewLog),
        (final CLMedia m) when media.isPreviewWaitingForDownload => flag
            ? AsyncValue.data(
                Uri.parse(
                  server!
                      .getEndpointURI('/media/${m.serverUID}/preview')
                      .toString(),
                ),
              )
            : const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  AsyncValue<Uri> getMediaUriAsync(CLMedia media) {
    try {
      return switch (media) {
        (final CLMedia m) when media.isMediaLocallyAvailable =>
          AsyncValue.data(Uri.file(getMediaAbsolutePath(m))),
        (final CLMedia m) when media.isMediaDownloadFailed =>
          throw Exception(m.mediaLog),
        (final CLMedia m) when !media.haveItOffline => server != null
            ? AsyncValue.data(
                Uri.parse(
                  server!
                      .getEndpointURI('/media/${m.serverUID}/'
                          'download?isOriginal=${m.mustDownloadOriginal}')
                      .toString(),
                ),
              )
            : throw Exception('Server Not connected'),
        (final CLMedia _) when media.isMediaWaitingForDownload =>
          const AsyncValue<Uri>.loading(),
        _ => throw UnimplementedError()
      };
    } catch (error, stackTrace) {
      return AsyncError(error, stackTrace);
    }
  }

  Uri getMediaUri(CLMedia media) {
    return Uri.file(getMediaAbsolutePath(media));
  }

  String getPreviewAbsolutePath(CLMedia media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );

  String getMediaAbsolutePath(CLMedia media) => p.join(
        directories.media.path.path,
        media.mediaFileName,
      );

  Future<String> createTempFile({required String ext}) async {
    final dir = directories.download.path; // FIXME temp Directory
    final fileBasename = 'keep_it_${DateTime.now().millisecondsSinceEpoch}';
    final absolutePath = '${dir.path}/$fileBasename.$ext';

    return absolutePath;
  }

  Future<bool?> shareMedia(
    BuildContext context,
    List<CLMedia> media,
  ) async {
    if (media.isEmpty) {
      return true;
    }
    final box = context.findRenderObject() as RenderBox?;
    return ShareManager.onShareFiles(
      context,
      media.map((e) => getMediaUri(e).toFilePath()).toList(),
      sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
    );
  }

  StoreCache copyWith({
    List<Collection>? collectionList,
    List<CLMedia>? mediaList,
    CLDirectories? directories,
    CLServer? server,
    Store? store,
  }) {
    return StoreCache(
      collectionList: collectionList ?? this.collectionList,
      mediaList: mediaList ?? this.mediaList,
      directories: directories ?? this.directories,
      server: server ?? this.server,
      store: store ?? this.store,
    );
  }

  StoreCache clearServer() {
    return StoreCache(
      collectionList: collectionList,
      mediaList: mediaList,
      directories: directories,
      server: null,
      store: store,
    );
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'StoreModel(collectionList count: ${collectionList.length}, mediaList: ${mediaList.length}, directories: ${directories.directories.keys.join(',')}, server: $server)';

  @override
  bool operator ==(covariant StoreCache other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.collectionList, collectionList) &&
        listEquals(other.mediaList, mediaList) &&
        other.directories == directories &&
        other.server == server;
  }

  @override
  int get hashCode =>
      collectionList.hashCode ^
      mediaList.hashCode ^
      directories.hashCode ^
      server.hashCode;

  Future<Collection> upsertCollection(
    Collection collection,
  ) async {
    final c = getCollectionById(collection.id);
    if (collection == c) return collection;
    final updated = await store.upsertCollection(collection);

    return updated;
  }

  Future<CLMedia?> _upsertMedia(
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
    int? id,
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
    return upsertMedia(
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
      id: id,
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
    );
  }

  Future<CLMedia?> upsertMedia(
    String path,
    CLMediaType type, {
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
    required int? id,
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
  }) async {
    final media = (id == null) ? null : getMediaById(id);

    final notesCollection = getCollectionByLabel('*** Notes') ??
        (await upsertCollection(
          const Collection(label: '*** Notes'),
        ));
    final defaultCollection = getCollectionByLabel(tempCollectionName) ??
        (await upsertCollection(
          Collection(label: tempCollectionName),
        ));

    final md5String0 = md5String ?? await File(path).checksum;
    final isAux0 = isAux ?? media?.isAux ?? false;
    final collectionId0 = collectionId ??
        media?.collectionId ??
        (isAux0 ? notesCollection : defaultCollection).id!;
    final savedMedia = CLMedia(
      /// These parameter are reset when a new content is provided
      id: id ?? media?.id,
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
      isHidden: collectionId0 == defaultCollection.id!,
      isDeleted: isDeleted ?? media?.isDeleted ?? false,
      isAux: isAux0,

      isEdited: isEdited ?? media?.isEdited ?? false,
      serverUID: serverUID ?? media?.serverUID,
      haveItOffline: haveItOffline ?? media?.haveItOffline ?? true,
      mustDownloadOriginal:
          mustDownloadOriginal ?? media?.mustDownloadOriginal ?? false,
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
  }

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
      CLMediaType.audio,
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
    return mediaFile.copyWith(name: downloadedFile, type: mimeType);
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
    return mediaFile.copyWith(type: mimeType);
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
          final duplicate = getMediaByMD5(md5String);
          if (duplicate != null) {
            // multiple duplicate may be imported together
            if (existingItems.where((e) => e.id == duplicate.id!).firstOrNull ==
                null) {
              existingItems.add(duplicate);
            }
          } else {
            // avoid recomputing md5
            final newItem =
                await _upsertMedia(item.name, item.type, md5String: md5String);
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
    onDone(
      existingItems: existingItems.where((e) => e.mediaLog == null).toList(),
      newItems: newItems.where((e) => e.mediaLog == null).toList(),
    );
  }

  Future<CLMedia?> updateMediaFromMap(Map<String, dynamic> map) async {
    final updated = await store.updateMediaFromMap(map);

    return updated;
  }

  Future<CLMedia?> updateMedia(CLMedia media) async {
    return store.upsertMedia(media);
  }

  Future<List<CLMedia>> updateMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    final updatedList = <CLMedia>[];

    for (final (i, m) in mediaMultiple.indexed) {
      final updated = await store.upsertMedia(m);
      if (updated != null) {
        updatedList.add(updated);
      }

      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.name,
        ),
      );
    }
    return updatedList;
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
      final withId = getCollectionByLabel(collection.label);
      updatedCollection = await upsertCollection(withId ?? collection);
    } else {
      updatedCollection = collection;
    }

    if (media.isNotEmpty) {
      final streamController = StreamController<Progress>();

      unawaited(
        updateMediaMultiple(
          media
              .map(
                (e) => e.copyWith(
                  isHidden: false,
                  collectionId: updatedCollection.id,
                ),
              )
              .toList(),
          onProgress: (progress) async {
            streamController.add(progress);
            await Future<void>.delayed(const Duration(microseconds: 10));
          },
        ).then((updatedMedia) async {
          streamController.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Successfully Imported',
            ),
          );
          await Future<void>.delayed(const Duration(microseconds: 10));
          await streamController.close();
          await onDone?.call(mediaMultiple: updatedMedia);
        }),
      );
      yield* streamController.stream;
    }
  }

  Future<bool> deleteCollectionById(
    int collectionId,
  ) async {
    final mediaMultiple = getMediaByCollectionId(collectionId);

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: true)).toList(),
    );

    return true;
  }

  Future<bool> deleteMediaById(int id) async {
    final media = getMediaById(id);
    if (media != null) {
      await updateMedia(media.copyWith(isDeleted: true));
    }

    return true;
  }

  Future<bool> deleteMediaMultiple(Set<int> ids2Delete) async {
    final mediaMultiple = getMediaMultipleByIds(ids2Delete.toList());

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: true)).toList(),
    );

    return true;
  }

  Future<bool> restoreMediaMultiple(Set<int> ids2Delete) async {
    final mediaMultiple = getMediaMultipleByIds(ids2Delete.toList());

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: false)).toList(),
    );

    return true;
  }

  Future<List<CLMedia>> getNotes(int mediaId) async {
    final noteIds = await store.reader.notesByMediaId(mediaId);
    return getMediaMultipleByIds(noteIds.map((e) => e.id!).toList());
  }

  Future<bool> permanentlyDeleteMediaMultiple(Set<int> ids2Delete) async {
    final medias = List<CLMedia?>.from(mediaList);

    final medias2Remove =
        medias.where((e) => ids2Delete.contains(e?.id)).toList();

    // Gather Notes
    final notes = <CLMedia>{};
    for (final m in medias2Remove) {
      notes.addAll(await getNotes(m!.id!));
    }

    if (medias2Remove.isNotEmpty) {
      medias.removeWhere((e) => ids2Delete.contains(e!.id));
      for (final m in medias2Remove) {
        if (m != null) {
          final notes = await getNotes(m.id!);
          await store.deleteMedia(m);
          await File(getMediaAbsolutePath(m)).deleteIfExists();
          await File(getPreviewAbsolutePath(m)).deleteIfExists();
          for (final n in notes) {
            await File(getMediaAbsolutePath(n)).deleteIfExists();
            await File(getPreviewAbsolutePath(n)).deleteIfExists();
          }
        }
      }

      return true;
    }

    return false;
  }

  Future<Collection> createCollectionIfMissing(String label) async {
    return (await store.reader.getCollectionByLabel(label)) ??
        await upsertCollection(Collection(label: label));
  }

  Future<MediaUpdatesFromServer> analyseChanges(
    List<dynamic> mediaMap, {
    required Future<Collection> Function(String label)
        createCollectionIfMissing,
  }) async {
    return store.reader.analyseChanges(
      mediaMap,
      createCollectionIfMissing: createCollectionIfMissing,
    );
  }

  Future<bool> togglePin(CLMedia media) async {
    return togglePinMultiple([media]);
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
      await updateMediaMultiple(pinnedMedia.map((e) => e.removePin()).toList());
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
    await updateMediaMultiple(updatedMedia);
    return true;
  }

  Future<bool> removeMediaFromGallery(
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);

    return res;
  }

  Future<List<CLMedia>> get checkDBForPreviewDownloadPending async {
    final q = store.reader.getQuery(
      DBQueries.previewDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.reader.readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> get checkDBForMediaDownloadPending async {
    final q = store.reader.getQuery(
      DBQueries.mediaDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.reader.readMultiple(q)).nonNullableList;
  }
}
