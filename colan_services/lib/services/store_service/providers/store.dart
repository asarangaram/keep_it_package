import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:local_store/local_store.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../internal/extensions/ext_store.dart';
import '../../../internal/extensions/list.dart';
import '../../colan_service/models/cl_server.dart';
import '../../colan_service/models/servers.dart';
import '../../colan_service/providers/downloader.dart';
import '../../colan_service/providers/servers.dart';
import '../../gallery_service/models/m5_gallery_pin.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../models/store_model.dart';
import '../models/url_handler.dart';

extension FilenameExtOnCLMedia on CLMedia {
  String get previewFileName => '${md5String}_tn.jpeg';
  String get mediaFileName => '$md5String$fExt';
}

class StoreNotifier extends StateNotifier<AsyncValue<StoreCache>> {
  StoreNotifier(this.ref, this.directoriesFuture)
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  final Ref ref;
  Future<CLDirectories> directoriesFuture;
  late final Store store;
  StoreCache? _currentState;
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  final String tempCollectionName = '*** Recently Captured';

  StoreCache? get currentState => _currentState;
  ProviderSubscription<Servers>? watchServer;

  set currentState(StoreCache? value) => updateState(value);
  CLServer? myServer;
  bool syncInPorgress = false;

  Future<void> updateState(StoreCache? value) async {
    _currentState = value;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return currentState!;
    });
    log('state updated: ', name: 'Store Notifier');
  }

  Future<void> _initialize() async {
    final deviceDirectories = await directoriesFuture;
    final db = deviceDirectories.db;
    const dbName = 'keepIt.db';
    final fullPath = p.join(db.pathString, dbName);

    store = await createStoreInstance(
      fullPath,
      onReload: () {},
    );

    await loadLocalDB();

    ref.listen(serversProvider, (prev, curr) {
      myServer = curr.myServer;

      if (prev?.myServerOnline != curr.myServerOnline) {
        // Transition has happened.
        if (curr.myServerOnline) {
          syncServer();
        } else {
          // server got disconnected,
        }
      }
    });
  }

  Future<void> loadLocalDB() async {
    final collections = await loadCollections();
    final medias = await loadMedia();
    currentState = StoreCache(
      collectionList: collections,
      mediaList: medias,
      directories: await directoriesFuture,
    );
  }

  Future<void> deleteMedia(CLMedia media) async {
    final mediaFile = File(_currentState!.getMediaAbsolutePath(media));
    final previewFile = File(_currentState!.getPreviewAbsolutePath(media));
    await mediaFile.deleteIfExists();
    await previewFile.deleteIfExists();
  }

  Future<void> syncServer() async {
    if (syncInPorgress) return;
    syncInPorgress = true;
    if (myServer != null) {
      final mediaMap = await myServer!.downloadMediaInfo();
      if (mediaMap != null) {
        await store.updateStoreFromMediaMapList(mediaMap);
        await Future<void>.delayed(const Duration(seconds: 1));
        await loadLocalDB();
        // await triggerDownloadsIfNeeded();
      }
    }
    syncInPorgress = false;
  }

  Future<void> triggerDownloadsIfNeeded() async {
    final group = DateTime.now().millisecondsSinceEpoch.toString();
    {
      final q = store.getQuery(
        DBQueries.previewDownloadPending,
      ) as StoreQuery<CLMedia>;
      final items = await store.readMultiple(q);

      for (final media in items) {
        if (media != null) {
          final previewFile =
              File(_currentState!.getPreviewAbsolutePath(media));

          await triggerDownload(
            media,
            previewFile,
            markPreviewAsDownloaded,
            startPreviewDownload,
            condition: true,
            group: group,
          );
        }
      }
    }
    {
      final q = store.getQuery(
        DBQueries.mediaDownloadPending,
      ) as StoreQuery<CLMedia>;
      final items = await store.readMultiple(q);

      for (final media in items) {
        if (media != null) {
          final mediaFile = File(_currentState!.getMediaAbsolutePath(media));

          await triggerDownload(
            media,
            mediaFile,
            markMediaAsDownloaded,
            startMediaDownload,
            condition: media.isMediaWaitingForDownload,
            group: group,
          );
        }
      }
    }
  }

  Future<void> triggerDownload(
    CLMedia media,
    File file,
    Future<void> Function(CLMedia media) onDownloaded,
    Future<void> Function(CLMedia media, String group) onStartDownload, {
    required bool condition,
    required String group,
  }) async {
    if (condition) {
      if (file.existsSync()) {
        await onDownloaded(media);
      } else {
        await onStartDownload(media, group);
      }
    }
  }

  Future<void> markPreviewAsDownloaded(CLMedia media) async {
    final mediaInDB = await store.updateMediaFromMap({
      'id': media.id,
      'previewLog': null,
      'isPreviewCached': true,
    });
    if (mediaInDB != null) {
      await refreshMedia(mediaInDB);
    }
  }

  Future<void> markMediaAsDownloaded(CLMedia media) async {
    final mediaInDB = await store.updateMediaFromMap({
      'id': media.id,
      'mediaLog': null,
      'isMediaCached': true,
      'isMediaOriginal': true,
    });
    if (mediaInDB != null) {
      await refreshMedia(mediaInDB);
    }
  }

  Future<void> startPreviewDownload(CLMedia media, String group) async {
    final directories = await directoriesFuture;
    if (myServer != null) {
      await ref.read(downloaderProvider).enqueue(
            url: myServer!
                .getEndpointURI('/media/${media.serverUID}/preview')
                .toString(),
            baseDirectory: BaseDirectory.applicationSupport,
            directory: directories.thumbnail.name,
            filename: media.previewFileName,
            group: group,
            onDone: ({errorLog}) async {
              final mediaInDB = await store.updateMediaFromMap({
                'id': media.id,
                'previewLog': errorLog,
                'isPreviewCached': errorLog == null,
              });
              if (mediaInDB != null) {
                await refreshMedia(mediaInDB);
              }
            },
          );
    }
  }

  Future<void> startMediaDownload(CLMedia media, String group) async {
    final directories = await directoriesFuture;
    if (myServer != null) {
      await ref.read(downloaderProvider).enqueue(
            url: myServer!
                .getEndpointURI(
                  '/media/${media.serverUID}/download?isOriginal=${media.mustDownloadOriginal}',
                )
                .toString(),
            baseDirectory: BaseDirectory.applicationSupport,
            directory: directories.media.name,
            filename: media.mediaFileName,
            group: group,
            onDone: ({errorLog}) async {
              final mediaInDB = await store.updateMediaFromMap({
                'id': media.id,
                'mediaLog': errorLog,
                'isMediaCached': errorLog == null,
                'isMediaOriginal':
                    errorLog == null && media.mustDownloadOriginal,
              });
              if (mediaInDB != null) {
                await refreshMedia(mediaInDB);
              }
            },
          );
    }
  }

  Future<List<Collection>> loadCollections() async {
    final q = store.getQuery(
      DBQueries.collections,
    ) as StoreQuery<Collection>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> loadMedia() async {
    final q = store.getQuery(
      DBQueries.medias,
    ) as StoreQuery<CLMedia>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<Collection> upsertCollection(Collection collection) async {
    if (currentState == null) {
      throw Exception('store is not ready');
    }
    final c = currentState!.getCollectionById(collection.id);

    if (collection == c) return collection;

    final updated = await store.upsertCollection(collection);

    if (c != null) {
      final index = currentState!.collectionList.indexOf(c);
      currentState = currentState!.copyWith(
        collectionList:
            currentState!.collectionList.replaceNthEntry(index, updated),
      );
    } else {
      currentState = currentState!.copyWith(
        collectionList: [...currentState!.collectionList, updated],
      );
    }

    return updated;
  }

  Future<CLMedia?> upsertMedia(
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
    if (currentState == null) {
      throw Exception('store is not ready');
    }

    final media = (id == null) ? null : currentState!.getMediaById(id);

    final notesCollection = currentState!.getCollectionByLabel('*** Notes') ??
        (await upsertCollection(
          const Collection(label: '*** Notes'),
        ));
    final defaultCollection =
        currentState!.getCollectionByLabel(tempCollectionName) ??
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
    var mediaFromDB = await store.upsertMedia(savedMedia, parents: parents);

    if (mediaFromDB != null) {
      final currentMediaPath = currentState!.getMediaAbsolutePath(mediaFromDB);
      File(path).copySync(currentMediaPath);
      mediaFromDB = await generateMediaPreview(media: mediaFromDB);

      final currentPreviewPath =
          currentState!.getPreviewAbsolutePath(mediaFromDB);
      if (media != null) {
        final mediaIndex = currentState!.getMediaIndexById(id);
        currentState = currentState!.copyWith(
          mediaList:
              currentState!.mediaList.replaceNthEntry(mediaIndex!, mediaFromDB),
        );
        final previousMediaPath = currentState!.getMediaAbsolutePath(media);
        final previousPreviewPath = currentState!.getPreviewAbsolutePath(media);
        if (currentMediaPath != previousMediaPath) {
          await File(previousMediaPath).deleteIfExists();
        }
        if (currentPreviewPath != previousPreviewPath) {
          await File(previousPreviewPath).deleteIfExists();
        }
      } else {
        currentState = currentState!
            .copyWith(mediaList: [...currentState!.mediaList, mediaFromDB]);
      }

      // FIXME: Should we delete the temp file referred by path?
    }
    return mediaFromDB;
  }

  Future<CLMedia> replaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    // As we are providing media id, all values are fetched from it.
    return (await upsertMedia(
      path,
      media.type,
      id: media.id,
      isEdited: true,
    ))!;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    return (await upsertMedia(
      path,
      media.type,
      isEdited: false,
      collectionId: media.collectionId,
      isHidden: media.isHidden,
      isDeleted: media.isDeleted,
      isAux: media.isAux,
      haveItOffline: media.haveItOffline,
      mustDownloadOriginal: media.mustDownloadOriginal,
    ))!;
  }

  Future<CLMedia?> newImageOrVideo(
    String path, {
    required bool isVideo,
    Collection? collection,
  }) async {
    return upsertMedia(
      path,
      isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection?.id,
    );
  }

  Future<CLMediaBase> tryDownloadMedia(
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

  Future<CLMediaBase> identifyMediaType(
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
    if (currentState == null) {
      throw Exception('Store is not ready');
    }
    final deviceDirectories = await directoriesFuture;
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
        deviceDirectories: deviceDirectories,
      );
      final item = await identifyMediaType(
        item1,
        deviceDirectories: deviceDirectories,
      );
      if (!item.type.isFile) {
        // Skip for now
      }
      if (item.type.isFile) {
        final file = File(item.name);
        if (file.existsSync()) {
          final md5String = await file.checksum;
          final duplicate = currentState!.getMediaByMD5(md5String);
          if (duplicate != null) {
            // multiple duplicate may be imported together
            if (existingItems.where((e) => e.id == duplicate.id!).firstOrNull ==
                null) {
              existingItems.add(duplicate);
            }
          } else {
            // avoid recomputing md5
            final newItem =
                await upsertMedia(item.name, item.type, md5String: md5String);
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

  Future<CLMedia?> updateMedia(CLMedia media) async {
    var mediaList = List<CLMedia>.from(currentState!.mediaList);

    final updated = await store.upsertMedia(media);
    if (updated != null) {
      final existing = currentState!.getMediaById(updated.id);

      if (existing != null) {
        mediaList =
            mediaList.replaceNthEntry(mediaList.indexOf(existing), updated);
      } else {
        mediaList = [...mediaList, updated];
      }
    }

    currentState = currentState!.copyWith(mediaList: mediaList);
    return updated;
  }

  Future<CLMedia?> refreshMedia(CLMedia media) async {
    var mediaList = List<CLMedia>.from(currentState!.mediaList);

    final existing = currentState!.getMediaById(media.id);

    if (existing != null) {
      mediaList = mediaList.replaceNthEntry(mediaList.indexOf(existing), media);
    } else {
      mediaList = [...mediaList, media];
    }

    currentState = currentState!.copyWith(mediaList: mediaList);
    return media;
  }

  Future<void> refreshMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    var mediaList = List<CLMedia>.from(currentState!.mediaList);

    for (final (i, m) in mediaMultiple.indexed) {
      if (m.id != null) {
        final updated = m;
        final existing = currentState!.getMediaById(updated.id);

        if (existing != null) {
          mediaList =
              mediaList.replaceNthEntry(mediaList.indexOf(existing), updated);
        } else {
          mediaList = [...mediaList, updated];
        }
      }

      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.name,
        ),
      );
    }
    currentState = currentState!.copyWith(mediaList: mediaList);

    return;
  }

  Future<List<CLMedia>> updateMediaMultiple(
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    var mediaList = List<CLMedia>.from(currentState!.mediaList);

    final updatedList = <CLMedia>[];
    for (final (i, m) in mediaMultiple.indexed) {
      if (m.id != null) {
        final updated = await store.upsertMedia(m);
        if (updated != null) {
          final existing = currentState!.getMediaById(updated.id);
          updatedList.add(updated);
          if (existing != null) {
            mediaList =
                mediaList.replaceNthEntry(mediaList.indexOf(existing), updated);
          } else {
            mediaList = [...mediaList, updated];
          }
        }
      }

      onProgress?.call(
        Progress(
          fractCompleted: i / mediaMultiple.length,
          currentItem: m.name,
        ),
      );
    }
    currentState = currentState!.copyWith(mediaList: mediaList);
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
      final withId = currentState!.getCollectionByLabel(collection.label);
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

  /// Delete all media ignoring those already in Recycle
  /// Don't delete CollectionDir / Collection from Media, required for restore
  Future<bool> deleteCollectionById(int collectionId) async {
    final mediaMultiple = currentState!.getMediaByCollectionId(collectionId);

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: true)).toList(),
    );

    return true;
  }

  Future<bool> deleteMediaById(int id) async {
    if (currentState == null) {
      return false;
    }
    final media = currentState!.getMediaById(id);
    if (media != null) {
      await updateMedia(media.copyWith(isDeleted: true));
    }

    return true;
  }

  Future<bool> deleteMediaMultiple(Set<int> ids2Delete) async {
    if (currentState == null) {
      return false;
    }

    final mediaMultiple =
        currentState!.getMediaMultipleByIds(ids2Delete.toList());

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: true)).toList(),
    );

    return true;
  }

  Future<bool> restoreMediaMultiple(Set<int> ids2Delete) async {
    if (currentState == null) {
      return false;
    }

    final mediaMultiple =
        currentState!.getMediaMultipleByIds(ids2Delete.toList());

    await updateMediaMultiple(
      mediaMultiple.map((e) => e.copyWith(isDeleted: false)).toList(),
    );

    return true;
  }

  Future<bool> permanentlyDeleteMediaMultiple(Set<int> ids2Delete) async {
    if (currentState == null) {
      return false;
    }
    final medias = List<CLMedia?>.from(currentState!.mediaList);

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
          await File(_currentState!.getMediaAbsolutePath(m)).deleteIfExists();
          await File(_currentState!.getPreviewAbsolutePath(m)).deleteIfExists();
          for (final n in notes) {
            await File(_currentState!.getMediaAbsolutePath(n)).deleteIfExists();
            await File(_currentState!.getPreviewAbsolutePath(n))
                .deleteIfExists();
          }
        }
      }

      currentState = currentState!.copyWith(mediaList: medias.nonNullableList);
      return true;
    }

    return false;
  }

  Future<void> onRefresh() async {
    await loadLocalDB();
    await syncServer();
  }

  Future<CLMedia> generateMediaPreview({
    required CLMedia media,
    int dimension = 256,
  }) async {
    if (currentState == null) return media;
    var updateMedia = media;
    try {
      final currentMediaPath = currentState!.getMediaAbsolutePath(media);
      final currentPreviewPath = currentState!.getPreviewAbsolutePath(media);
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
    final deviceDirectories = await directoriesFuture;
    if (mediaMultiple.isEmpty) {
      return true;
    }
    final updatedMedia = <CLMedia>[];
    for (final media in mediaMultiple) {
      if (media.id != null) {
        final pin = await albumManager.addMedia(
          p.join(
            deviceDirectories.media.pathString,
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

  Future<List<CLMedia>> getNotes(int mediaId) async {
    // FIXME better to have a raw query to directly read indices
    if (_currentState == null) return [];
    final q = store.getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
        as StoreQuery<CLMedia>;
    final noteIds =
        (await store.readMultiple(q)).map((e) => e!.id!).nonNullableList;

    return _currentState!.getMediaMultipleByIds(noteIds);
  }
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, AsyncValue<StoreCache>>((ref) {
  final deviceDirectories = ref.watch(deviceDirectoriesProvider.future);
  final notifier = StoreNotifier(ref, deviceDirectories);

  return notifier;
});
