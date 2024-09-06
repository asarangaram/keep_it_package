import 'package:colan_services/services/store_service/extensions/list.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../models/store_model.dart';

class StoreNotifier extends StateNotifier<AsyncValue<StoreModel>> {
  StoreNotifier(this.ref, this.directoriesFuture)
      : super(const AsyncValue.loading()) {
    _initialize();
  }
  final Ref ref;
  Future<CLDirectories> directoriesFuture;
  late final Store store;
  StoreModel? _currentState;

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
    List<CLMedia>? mediaMultiple,
    CLMedia? media,
    Collection? collection,
  }) async {
    return null;
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
      collection: collection,
    );
  }

  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    Future<void> Function({required List<CLMedia> mediaMultiple})? onDone,
  }) async* {
    yield const Progress(fractCompleted: 0, currentItem: '');
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
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, AsyncValue<StoreModel>>((ref) {
  final deviceDirectories = ref.watch(deviceDirectoriesProvider.future);
  return StoreNotifier(ref, deviceDirectories);
});
