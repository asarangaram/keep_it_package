import 'dart:io';

import 'package:colan_services/services/store_service/extensions/list.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:heif_converter/heif_converter.dart';
import 'package:image/image.dart' as img;
import 'package:local_store/local_store.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../gallery_service/models/m5_gallery_pin.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../models/store_model.dart';
import '../models/url_handler.dart';

class StoreNotifier extends StateNotifier<AsyncValue<StoreModel>> {
  StoreNotifier(this.ref, this.directoriesFuture)
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  final Ref ref;
  Future<CLDirectories> directoriesFuture;
  late final Store store;
  StoreModel? _currentState;
  final AlbumManager albumManager = AlbumManager(albumName: 'KeepIt');
  final String tempCollectionName = '*** Recently Captured';

  StoreModel? get currentState => _currentState;

  set currentState(StoreModel? value) => updateState(value);

  Future<void> updateState(StoreModel? value) async {
    _currentState = value;
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return currentState!;
    });
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

    await syncServer();
  }

  Future<void> loadLocalDB() async {
    final collections = await loadCollections();
    final medias = await loadMedia();
    currentState = StoreModel(
      collectionList: collections,
      mediaList: medias,
      directories: await directoriesFuture,
    );
  }

  Future<void> syncServer() async {}

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

  Future<bool> deleteCollectionById(int id) async {
    if (currentState == null) {
      return false;
    }
    final collections = List<Collection?>.from(currentState!.collectionList);
    final c = collections.firstWhere(
      (collection) => collection?.id == id,
      orElse: () => null,
    );
    if (c != null) {
      if (collections.remove(c)) {
        await store.deleteCollection(c);
        currentState =
            currentState!.copyWith(collectionList: collections.nonNullableList);
        return true;
      }
    }

    return false;
  }

  Future<bool> deleteMediaById(int id) async {
    if (currentState == null) {
      return false;
    }
    final medias = List<CLMedia?>.from(currentState!.mediaList);
    final c = medias.firstWhere(
      (collection) => collection?.id == id,
      orElse: () => null,
    );
    if (c != null) {
      if (medias.remove(c)) {
        await store.deleteMedia(c);
        currentState =
            currentState!.copyWith(mediaList: medias.nonNullableList);
        return true;
      }
    }

    return false;
  }

  Future<bool> deleteMediaMultiple(Set<int> idsToRemove) async {
    if (currentState == null) {
      return false;
    }
    final medias = List<CLMedia?>.from(currentState!.mediaList);

    final medias2Remove =
        medias.where((e) => idsToRemove.contains(e?.id)).toList();
    if (medias2Remove.isNotEmpty) {
      medias.removeWhere((e) => idsToRemove.contains(e!.id));
      for (final m in medias2Remove) {
        if (m != null) {
          await store.deleteMedia(m);
        }
      }
      currentState = currentState!.copyWith(mediaList: medias.nonNullableList);
      return true;
    }

    return false;
  }

  Future<Collection?> upsertCollection(Collection collection) async {
    return null;
  }

  Future<CLMedia?> upsertMedia(
    String path,
    CLMediaType type, {
    int? id,
    int? collectionId,
    bool isAux = false,
    List<CLMedia>? parents,
    String? md5String,
  }) async {
    if (currentState == null) {
      throw Exception('store is not ready');
    }
    int? collectionId0;
    final Collection collection;
    final media = (id == null) ? null : currentState!.getMediaById(id);
    collectionId0 = collectionId ?? media?.collectionId;

    final existingCollection = collectionId0 == null
        ? null
        : currentState!.getCollectionById(collectionId0);

    if (isAux) {
      collection = currentState!.getCollectionByLabel('*** Notes') ??
          await store.upsertCollection(
            const Collection(label: '*** Notes'),
          );
    } else {
      collection = existingCollection ??
          currentState!.getCollectionByLabel(tempCollectionName) ??
          await store.upsertCollection(
            Collection(label: tempCollectionName),
          );
    }
    final md5String0 = md5String ?? await File(path).checksum;
    final savedMedia = media?.copyWith(
          name: p.basename(path),
          fExt: p.extension(path),
          type: type,
          collectionId: collection.id,
          md5String: md5String0,
          isHidden: existingCollection == null,
          isAux: isAux,
          isDeleted: false,
        ) ??
        CLMedia(
          name: p.basename(path),
          fExt: p.extension(path),
          type: type,
          collectionId: collection.id,
          md5String: md5String0,
          isHidden: collectionId0 == null,
          isAux: isAux,
          isPreviewCached: false,
          isMediaCached: false,
          isMediaOriginal: true,
          isEdited: false,
          previewLog: null,
          mediaLog: null,
          serverUID: null,
          haveItOffline: true,
          mustDownloadOriginal: true,
        );
    final mediaFromDB = await store.upsertMedia(savedMedia, parents: parents);

    if (mediaFromDB != null) {
      final currentMediaPath = currentState!.getMediaAbsolutePath(mediaFromDB);
      final currentPreviewPath =
          currentState!.getPreviewAbsolutePath(mediaFromDB);
      File(path).copySync(currentMediaPath);

      await generatePreview(
        inputFile: currentMediaPath,
        outputFile: currentPreviewPath,
        type: mediaFromDB.type,
      );

      if (media != null) {
        final previousMediaPath = currentState!.getMediaAbsolutePath(media);
        final previousPreviewPath = currentState!.getPreviewAbsolutePath(media);
        if (currentMediaPath != previousMediaPath) {
          await File(previousMediaPath).deleteIfExists();
        }
        if (currentPreviewPath != previousPreviewPath) {
          await File(previousPreviewPath).deleteIfExists();
        }
      }

      // FIXME: Should we delete the temp file referred by path?
    }
    return mediaFromDB;
  }

  Future<CLMedia> replaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    return media;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    String path, {
    required CLMedia media,
  }) async {
    return media;
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
    onDone(existingItems: existingItems, newItems: newItems);
  }

  Stream<Progress> moveToCollectionStream({
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  }) async* {
    yield const Progress(fractCompleted: 0, currentItem: '');
  }

  Future<bool> togglePin(CLMedia media) async {
    return togglePinMultiple([media]);
  }

  Future<bool> togglePinMultiple(List<CLMedia> media) async {
    return false;
  }

  Future<bool> restoreMediaMultiple(List<CLMedia> media) async {
    return false;
  }

  Future<bool> permanentlyDeleteMediaMultiple(List<CLMedia> media) async {
    return false;
  }

  Future<void> onRefresh() async {}

  static Future<bool> generatePreview({
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
            throw Exception(' Failed to convert HEIC file to JPEG');
          }
          inputImage = img.decodeImage(File(jpegPath).readAsBytesSync());
        } else {
          inputImage = img.decodeImage(File(inputFile).readAsBytesSync());
        }
        if (inputImage == null) {
          throw Exception('Failed to decode Image');
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
        return true;

      case CLMediaType.video:
        await File(outputFile).deleteIfExists();
        final session = await FFmpegKit.execute(
          '-i $inputFile '
          '-ss 00:00:01.000 '
          '-vframes 1 '
          '-vf "scale=$dimension:-1" '
          '$outputFile',
        );
        /* 
      print(log); */
        final returnCode = await session.getReturnCode();
        if (!ReturnCode.isSuccess(returnCode)) {
          await File(outputFile).deleteIfExists();
          final log = await session.getAllLogsAsString();
          throw Exception(log);
        }

        return ReturnCode.isSuccess(returnCode);

      case CLMediaType.text:
      case CLMediaType.url:
      case CLMediaType.audio:
      case CLMediaType.file:
        throw Exception("Unsupported Media Type. Preview can't be generated");
    }
  }
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, AsyncValue<StoreModel>>((ref) {
  final deviceDirectories = ref.watch(deviceDirectoriesProvider.future);
  return StoreNotifier(ref, deviceDirectories);
});
