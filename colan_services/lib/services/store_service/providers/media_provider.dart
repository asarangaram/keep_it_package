import 'package:colan_services/services/store_service/providers/thumbnail_generator.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../extensions/global_preference.dart';
import '../extensions/store_reader.dart';
import '../extensions/store_upsert.dart';
import '../models/media_with_details.dart';
import '../models/store_manager.dart';
import '../providers/p2_db_manager.dart';

class MediaNotifier extends StateNotifier<MediaWithDetailsList> {
  MediaNotifier(this.ref, this.storeManagerFuture)
      : super(const MediaWithDetailsList([])) {
    _initialize();
  }
  final Ref ref;
  final Future<StoreManager> storeManagerFuture;
  Future<void> _initialize() async => load();

  Future<void> load() async {
    final storeManager = await storeManagerFuture;
    final globalPreferences =
        await StoreExtOnDownloadMediaGlobalPreference.load();

    final media = await storeManager.getMedias();
    final mediaPreferences = await storeManager.getMediaPrefernces();
    final mediaStatus = await storeManager.getMediaStatus();
    final notes = <CLMedia, List<CLMedia>>{};
    for (final mediaItem in media) {
      final notesList = await storeManager.getNotesByID(mediaItem.id!);
      if (notesList.isNotEmpty) {
        notes[mediaItem] = notesList;
      }
    }
    final mediaWithDetails = media.map((mediaItem) {
      final preference = mediaPreferences.firstWhere(
        (pref) => pref.id == mediaItem.id,
        orElse: () => MediaPreference(
          id: mediaItem.id!,
          haveItOffline: globalPreferences.haveItOffline,
          mustDownloadOriginal: globalPreferences.mustDownloadOriginal,
        ),
      );

      final status = mediaStatus.firstWhere(
        (stat) => stat.id == mediaItem.id,
        orElse: () => DefaultMediaStatus(id: mediaItem.id!),
      );

      return MediaWithDetails(
        media: mediaItem,
        preference: preference,
        status: status,
        notes: notes[mediaItem] ?? [],
      );
    }).toList();
    state = MediaWithDetailsList(mediaWithDetails);
  }

  Future<CLMedia?> upsertMediaFromFile(
    String path,
    CLMediaType type, {
    int? id,
    int? collectionId,
    bool isAux = false,
    List<CLMedia>? parents,
    String? md5String,
  }) async {
    final storeManager = await storeManagerFuture;

    final globalPreferences =
        await StoreExtOnDownloadMediaGlobalPreference.load();

    final media = await storeManager.upsertMediaFromFile(
      path,
      type,
      id: id,
      collectionId: collectionId,
      isAux: isAux,
      parents: parents,
      md5String: md5String,
    );
    if (media?.id != null) {
      /// Being a new media, let's
      /// *  clear the preview Cache status
      ///
      final mediaStatus = (await storeManager.getMediaStatusById(media!.id!))
              ?.clearPreviewCache() ??
          DefaultMediaStatus(id: media.id!);
      await storeManager.store.upsertMediaStatus(mediaStatus);

      final mediaPreference =
          await storeManager.getMediaPreferenceById(media.id!) ??
              MediaPreference(
                id: media.id!,
                haveItOffline: globalPreferences.haveItOffline,
                mustDownloadOriginal: globalPreferences.mustDownloadOriginal,
              );
      final notes = await storeManager.getNotesByID(media.id!);
      final updated = MediaWithDetails(
        media: media,
        preference: mediaPreference,
        status: mediaStatus,
        notes: notes,
      );
      await ref
          .read(previewCacheManagerProvider(storeManager))
          .generatePreview(updated);

      state = await state.upsert(updated);
    }
    return media;
  }

  Stream<Progress> analyseMediaStream({
    required List<CLMediaBase> mediaFiles,
    required void Function({
      required List<CLMedia> mediaMultiple,
    }) onDone,
  }) async* {
    final storeManager = await storeManagerFuture;
    yield* storeManager.analyseMediaStream(
      mediaFiles: mediaFiles,
      onDone: ({required List<CLMedia> mediaMultiple}) {
        load();
        onDone(mediaMultiple: mediaMultiple);
      },
    );
  }

  Future<void> updateMediaStatus(
    int id, {
    bool? isPreviewCached,
    bool? isMediaCached,
    String? previewLog,
    String? mediaLog,
    bool? isMediaOriginal,
    int? serverUID,
    bool? isEdited,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) async {
    final updated = await state.updateMediaStatus(
      id,
      isPreviewCached: isPreviewCached,
      isMediaCached: isMediaCached,
      previewLog: previewLog,
      mediaLog: mediaLog,
      isMediaOriginal: isMediaOriginal,
      serverUID: serverUID,
      isEdited: isEdited,
      haveItOffline: haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal,
    );
    final storeManager = await storeManagerFuture;
    await storeManager.store.upsertMediaStatus(updated.items[id].status);
    state = updated;
  }

  Future<void> markPreviewCached(int id) async {
    await updateMediaStatus(id, isPreviewCached: true);
  }

  Future<void> setPreviewError(int id, String errorString) async {
    await updateMediaStatus(id, previewLog: errorString);
  }
}

extension UtilOnMediaNotifier on MediaNotifier {
  Future<CLMedia> newImageOrVideo(
    String fileName, {
    required bool isVideo,
    Collection? collection,
  }) async =>
      (await upsertMediaFromFile(
        fileName,
        isVideo ? CLMediaType.video : CLMediaType.image,
      ))!;

  Future<CLMedia> replaceMedia(CLMedia originalMedia, String outFile) async =>
      (await upsertMediaFromFile(
        outFile,
        originalMedia.type,
        id: originalMedia.id,
        collectionId: originalMedia.collectionId,
      ))!;

  Future<CLMedia> cloneAndReplaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async =>
      (await upsertMediaFromFile(
        outFile,
        originalMedia.type,
        collectionId: originalMedia.collectionId,
      ))!;

  Future<CLMedia> upsertNote(
    String path,
    CLMediaType type, {
    required List<CLMedia> mediaMultiple,
    CLMedia? note,
  }) async =>
      (await upsertMediaFromFile(
        path,
        type,
        id: note?.id,
        isAux: true,
        parents: mediaMultiple,
      ))!;
}

final mediaProvider =
    StateNotifierProvider<MediaNotifier, MediaWithDetailsList>((ref) {
  return MediaNotifier(ref, ref.watch(storeProvider.future));
});
