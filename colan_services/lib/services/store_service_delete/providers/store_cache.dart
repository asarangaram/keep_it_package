import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/extensions/list.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../models/store_model.dart';
import 'store.dart';

class StoreCacheNotifier extends StateNotifier<AsyncValue<StoreCache>> {
  StoreCacheNotifier(this.ref, this.directoriesFuture, this.storeFuture)
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  final Ref ref;
  Future<CLDirectories> directoriesFuture;
  final Future<Store> storeFuture;
  late StoreCache _currentState;

  StoreCache get currentState1 => _currentState;

  set currentState1(StoreCache value) => updateState(value);

  Future<void> updateState(StoreCache value) async {
    _currentState = value;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return currentState1;
    });

    //  log('state updated: $state ', name: 'Store Notifier');
  }

  Future<void> _initialize() async {
    _currentState = StoreCache(
      collectionList: const [],
      mediaList: const [],
      directories: await directoriesFuture,
      server: null,
      store: await storeFuture,
    );

    requestReload();
  }

  bool isLoading = false;
  bool reloadRequested = false;

  void requestReload() {
    reloadRequested = true;
    if (isLoading) {
      return;
    }
    loadLocalDB();
  }

  Future<void> loadLocalDB() async {
    isLoading = true;
    while (reloadRequested) {
      reloadRequested = false;

      final collections = await loadCollections();
      final medias = await loadMedia();
      currentState1 = currentState1.copyWith(
        collectionList: collections,
        mediaList: medias,
      );
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    isLoading = false;
  }

  Future<void> deleteMedia(CLMedia media) async {
    final mediaFile = File(_currentState.getMediaAbsolutePath(media));
    final previewFile = File(_currentState.getPreviewAbsolutePath(media));
    await mediaFile.deleteIfExists();
    await previewFile.deleteIfExists();
  }

  Future<List<Collection>> loadCollections() async {
    final store = await storeFuture;
    final q = store.reader.getQuery(
      DBQueries.collections,
    ) as StoreQuery<Collection>;
    return (await store.reader.readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> loadMedia() async {
    final store = await storeFuture;
    final q = store.reader.getQuery(
      DBQueries.medias,
    ) as StoreQuery<CLMedia>;
    return (await store.reader.readMultiple(q)).nonNullableList;
  }

  Future<Collection> upsertCollection(
    StoreCache storeCache,
    Collection collection,
  ) async {
    final updated = await storeCache.upsertCollection(collection);
    requestReload();
    return updated;
  }

  Future<CLMedia?> upsertMedia(
    StoreCache storeCache,
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
    final updated = storeCache.upsertMedia(
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
    requestReload();
    return updated;
  }

  Future<CLMedia> replaceMedia(
    StoreCache storeCache,
    String path, {
    required CLMedia media,
  }) async {
    // As we are providing media id, all values are fetched from it.
    return (await upsertMedia(
      storeCache,
      path,
      media.type,
      id: media.id,
      isEdited: true,
    ))!;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    StoreCache storeCache,
    String path, {
    required CLMedia media,
  }) async {
    return (await upsertMedia(
      storeCache,
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
    StoreCache storeCache,
    String path, {
    required bool isVideo,
    Collection? collection,
  }) async {
    return upsertMedia(
      storeCache,
      path,
      isVideo ? CLMediaType.video : CLMediaType.image,
      collectionId: collection?.id,
    );
  }

  Stream<Progress> analyseMediaStream(
    StoreCache storeCache, {
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> existingItems,
      required List<CLMedia> newItems,
    }) onDone,
  }) async* {
    yield* storeCache.analyseMediaStream(
      mediaFiles: mediaFiles,
      onDone: ({
        required List<CLMedia> existingItems,
        required List<CLMedia> newItems,
      }) {
        requestReload();
        onDone(existingItems: existingItems, newItems: newItems);
      },
    );
  }

  Future<CLMedia?> updateMediaFromMap(
    StoreCache storeCache,
    Map<String, dynamic> map,
  ) async {
    final updated = storeCache.updateMediaFromMap(map);
    requestReload();
    return updated;
  }

  Future<CLMedia?> updateMedia(StoreCache storeCache, CLMedia media) async {
    final updated = await storeCache.updateMedia(media);
    requestReload();
    return updated;
  }

  Future<List<CLMedia>> updateMediaMultiple(
    StoreCache storeCache,
    List<CLMedia> mediaMultiple, {
    void Function(Progress progress)? onProgress,
  }) async {
    final updated =
        storeCache.updateMediaMultiple(mediaMultiple, onProgress: onProgress);
    requestReload();
    return updated;
  }

  Stream<Progress> moveToCollectionStream(
    StoreCache storeCache, {
    required List<CLMedia> media,
    required Collection collection,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  }) async* {
    yield* storeCache.moveToCollectionStream(
      media: media,
      collection: collection,
      onDone: ({required List<CLMedia> mediaMultiple}) async {
        await onDone?.call(mediaMultiple: mediaMultiple);
        requestReload();
      },
    );
  }

  /// Delete all media ignoring those already in Recycle
  /// Don't delete CollectionDir / Collection from Media, required for restore
  Future<bool> deleteCollectionById(
    StoreCache storeCache,
    int collectionId,
  ) async {
    final result = storeCache.deleteCollectionById(collectionId);
    requestReload();
    return result;
  }

  Future<bool> deleteMediaById(StoreCache storeCache, int id) async {
    final result = storeCache.deleteMediaById(id);
    requestReload();
    return result;
  }

  Future<bool> deleteMediaMultiple(
    StoreCache storeCache,
    Set<int> ids2Delete,
  ) async {
    final result = storeCache.deleteMediaMultiple(ids2Delete);
    requestReload();
    return result;
  }

  Future<bool> restoreMediaMultiple(
    StoreCache storeCache,
    Set<int> ids2Delete,
  ) async {
    final result = storeCache.restoreMediaMultiple(ids2Delete);
    requestReload();
    return result;
  }

  Future<bool> permanentlyDeleteMediaMultiple(
    StoreCache storeCache,
    Set<int> ids2Delete,
  ) async {
    final result = storeCache.permanentlyDeleteMediaMultiple(ids2Delete);
    requestReload();
    return result;
  }

  Future<bool> togglePin(StoreCache storeCache, CLMedia media) async {
    return togglePinMultiple(storeCache, [media]);
  }

  Future<bool> togglePinMultiple(
    StoreCache storeCache,
    List<CLMedia> media,
  ) async {
    return storeCache.togglePinMultiple(media);
  }

  Future<void> onRefresh() async {
    await loadLocalDB();
  }
}

final storeCacheProvider =
    StateNotifierProvider<StoreCacheNotifier, AsyncValue<StoreCache>>((ref) {
  final deviceDirectories = ref.watch(deviceDirectoriesProvider.future);
  final storeFuture = ref.watch(storeProvider.future);
  final notifier = StoreCacheNotifier(ref, deviceDirectories, storeFuture);

  return notifier;
});
