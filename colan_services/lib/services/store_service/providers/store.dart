import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/store_model.dart';

class StoreNotifier extends StateNotifier<StoreModel> {
  StoreNotifier(super.store);

  Future<bool> deleteCollection(Collection collection) async {
    return false;
  }

  Future<bool> deleteMedia(CLMedia media) async {
    return false;
  }

  Future<bool> deleteMediaMultiple(List<CLMedia> media) async {
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
    return null;
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
    return false;
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

final storeProvider = StateNotifierProvider<StoreNotifier, StoreModel>((ref) {
  return StoreNotifier(StoreModel());
});
