import 'package:collection/collection.dart';

import 'package:meta/meta.dart';

import 'package:store/store.dart';

import '../../extensions/list_ext.dart';

@immutable
class TrackedMedia {
  const TrackedMedia(this.current, this.update);
  final CLMedia current;
  final CLMedia update;

  @override
  bool operator ==(covariant TrackedMedia other) {
    if (identical(this, other)) return true;

    return other.current == current && other.update == update;
  }

  @override
  int get hashCode => current.hashCode ^ update.hashCode;

  @override
  String toString() => 'TrackedMedia(current: $current, update: $update)';
}

@immutable
class MediaUpdatesFromServer {
  const MediaUpdatesFromServer({
    required this.deletedOnServer,
    required this.deletedOnLocal,
    required this.updatedOnServer,
    required this.updatedOnLocal,
    required this.newOnServer,
    required this.newOnLocal,
  });
  final List<CLMedia> deletedOnServer;
  final List<CLMedia> deletedOnLocal;
  final List<CLMedia> updatedOnServer;
  final List<TrackedMedia> updatedOnLocal;
  final List<CLMedia> newOnServer;
  final List<CLMedia> newOnLocal;

  @override
  bool operator ==(covariant MediaUpdatesFromServer other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.deletedOnServer, deletedOnServer) &&
        listEquals(other.deletedOnLocal, deletedOnLocal) &&
        listEquals(other.updatedOnServer, updatedOnServer) &&
        listEquals(other.updatedOnLocal, updatedOnLocal) &&
        listEquals(other.newOnServer, newOnServer) &&
        listEquals(other.newOnLocal, newOnLocal);
  }

  @override
  int get hashCode {
    return deletedOnServer.hashCode ^
        deletedOnLocal.hashCode ^
        updatedOnServer.hashCode ^
        updatedOnLocal.hashCode ^
        newOnServer.hashCode ^
        newOnLocal.hashCode;
  }

  @override
  String toString() {
    return 'MediaUpdatesFromServer( '
        'deletedOnServer: ${deletedOnServer.length}, '
        'deletedOnLocal: ${deletedOnLocal.length}, '
        'updatedOnServer: ${updatedOnServer.length}, '
        'updatedOnLocal: ${updatedOnLocal.length}, '
        'newOnServer: ${newOnServer.length}, '
        'newOnLocal: ${newOnLocal.length})';
  }
}

extension StoreReaderExt on StoreReader {
  Future<List<CLMedia>> notesByMediaId(int mediaId) async {
    final q = getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
        as StoreQuery<CLMedia>;
    return (await readMultiple(q)).nonNullableList;
  }

  Future<CLMedia?> getMedia({
    int? id,
    int? serverUID,
    String? md5String,
  }) async {
    CLMedia? media;
    if (id != null) {
      media = await getMediaById(id);
      if (media != null) return media;
    }
    if (serverUID != null) {
      media = await getMediaByServerUID(serverUID);
      if (media != null) return media;
    }
    if (md5String != null) {
      media = await getMediaByMD5String(md5String);
      if (media != null) return media;
    }
    return null;
  }

  Future<List<T>> readMultipleByQuery<T>(StoreQuery<T> q) async {
    return (await readMultiple<T>(q)).nonNullableList;
  }
}
