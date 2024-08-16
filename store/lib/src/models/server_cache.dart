import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';
import 'store.dart';

abstract class ServerCache extends Store {
  @override
  Future<Collection> upsertCollection(
    Collection collection, {
    bool forceUpdate = false,
    bool fromServer = false,
  });
  @override
  Future<CLMedia?> upsertMedia(
    CLMedia media, {
    bool forceUpdate = false,
    bool fromServer = false,
  });
  @override
  Future<CLNote?> upsertNote(
    CLNote note,
    List<CLMedia> mediaList, {
    bool forceUpdate = false,
    bool fromServer = false,
  });

  @override
  Future<void> deleteCollection(
    Collection collection, {
    bool forceUpdate = false,
    bool fromServer = false,
  });
  @override
  Future<void> deleteMedia(
    CLMedia media, {
    required bool permanent,
    bool forceUpdate = false,
    bool fromServer = false,
  });
  @override
  Future<void> deleteNote(
    CLNote note, {
    bool forceUpdate = false,
    bool fromServer = false,
  });

  @override
  Future<List<Object?>?> getDBRecords();

  @override
  Future<T?> read<T>(StoreQuery<T> query);

  @override
  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  @override
  Future<void> reloadStore();

  @override
  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  @override
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  @override
  void dispose();
}

abstract class MyAPI {
  void fetchData(String endpoint); // Abstract method
}

class ExistingAPIImplementation extends MyAPI {
  @override
  void fetchData(String endpoint) {
    print('Existing implementation fetching data from $endpoint...');
    // Original logic here
  }
}

abstract class NewAPIImplementation extends MyAPI {
  @override
  void fetchData(String endpoint, {int timeout = 5000, bool cache = true});
}
