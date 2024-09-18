// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:developer' as dev;
import 'dart:io';

import 'package:colan_services/services/colan_service/models/cl_server.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../internal/extensions/ext_cl_media.dart';
import '../../../internal/extensions/list.dart';
import '../../sharing_service/models/share_files.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

@immutable
class StoreCache {
  const StoreCache({
    required this.collectionList,
    required this.mediaList,
    required this.directories,
    required this.server,
    this.allowOnlineViewIfNotDownloaded = false,
  });
  final List<Collection> collectionList;
  final List<CLMedia> mediaList;
  final CLDirectories directories;
  final CLServer? server;
  final bool allowOnlineViewIfNotDownloaded;

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
      collectionList.where((e) => !e.label.startsWith('***'));

  Iterable<CLMedia> get validMedia {
    final iterable =
        mediaList.where((e) => !(e.isDeleted ?? false) && e.mediaLog == null);

    return iterable.where(
      (e) =>
          (e.isMediaLocallyAvailable || (!e.haveItOffline && server != null)) &&
              e.isPreviewLocallyAvailable ||
          (e.isPreviewWaitingForDownload && server != null),
    );
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
  }) {
    return StoreCache(
      collectionList: collectionList ?? this.collectionList,
      mediaList: mediaList ?? this.mediaList,
      directories: directories ?? this.directories,
      server: server ?? this.server,
    );
  }

  StoreCache clearServer() {
    return StoreCache(
      collectionList: collectionList,
      mediaList: mediaList,
      directories: directories,
      server: null,
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
}
