import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../cl_server.dart';
import 'create.dart';

@immutable
class CachedServer extends CLServer with Store {
  CachedServer({
    required super.name,
    required super.port,
    required int id,
    required this.isOnline,
    required this.cachedStore,
  }) : super(id: id);

  Future<CachedServer> createCachedServer({
    required String name,
    required int port,
    required int id,
    required String cacheDir,
  }) async {
    final cachedStore = await createStoreInstance(
      '$cacheDir/${super.dbPath}',
      onReload: onReload,
    );

    final cachedServer = CachedServer(
      name: name,
      port: port,
      id: id,
      isOnline: isOnline,
      cachedStore: cachedStore,
    );

    //download Collections and Media
    await downloadCollections();
    await downloadMedia();

    return cachedServer;
  }

  Future<void> downloadCollections() async {}

  Future<void> downloadMedia() async {}

  void onDispose() {
    cachedStore.dispose();
  }

  final Store cachedStore;
  final bool isOnline;

  void onReload() {
    reloadStore();
  }

  @override
  CachedServer copyWith({
    String? name,
    int? port,
    int? id,
    Store? store,
    bool? isOnline,
  }) {
    return CachedServer(
      name: name ?? this.name,
      port: port ?? this.port,
      id: id ?? this.id!,
      cachedStore: store ?? cachedStore,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  Future<void> deleteCollection(Collection collection) {
    // TODO(anandas): implement deleteCollection
    throw UnimplementedError();
  }

  @override
  Future<void> deleteMedia(CLMedia media, {required bool permanent}) {
    // TODO(anandas): implement deleteMedia
    throw UnimplementedError();
  }

  @override
  Future<void> deleteNote(CLNote note) {
    // TODO(anandas): implement deleteNote
    throw UnimplementedError();
  }

  @override
  void dispose() {
    // TODO(anandas): implement dispose
  }

  @override
  Future<List<Object?>?> getDBRecords() {
    // TODO(anandas): implement getDBRecords
    throw UnimplementedError();
  }

  @override
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters}) {
    // TODO(anandas): implement getQuery
    throw UnimplementedError();
  }

  @override
  Future<T?> read<T>(StoreQuery<T> query) {
    // TODO(anandas): implement read
    throw UnimplementedError();
  }

  @override
  Future<List<T?>> readMultiple<T>(StoreQuery<T> query) {
    // TODO(anandas): implement readMultiple
    throw UnimplementedError();
  }

  @override
  Future<void> reloadStore() {
    throw UnimplementedError();
  }

  @override
  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery) {
    // TODO(anandas): implement storeReaderStream
    throw UnimplementedError();
  }

  @override
  Future<Collection> upsertCollection(Collection collection) {
    // TODO(anandas): implement upsertCollection
    throw UnimplementedError();
  }

  @override
  Future<CLMedia?> upsertMedia(CLMedia media) {
    // TODO(anandas): implement upsertMedia
    throw UnimplementedError();
  }

  @override
  Future<CLNote?> upsertNote(CLNote note, List<CLMedia> mediaList) {
    // TODO(anandas): implement upsertNote
    throw UnimplementedError();
  }

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'CachedServer(name: $name, port: $port, id: $id, store: $cachedStore, isOnline: $isOnline)';

  @override
  bool operator ==(covariant CachedServer other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.port == port &&
        other.id == id &&
        other.cachedStore == cachedStore &&
        other.isOnline == isOnline;
  }

  @override
  int get hashCode => super.hashCode ^ cachedStore.hashCode ^ isOnline.hashCode;
}
