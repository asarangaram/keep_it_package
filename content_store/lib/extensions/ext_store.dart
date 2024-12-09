import 'package:store/store.dart';

extension StoreReaderExt on StoreReader {
  Future<List<CLMedia>> notesByMediaId(int mediaId) async {
    final q = getQuery(DBQueries.notesByMediaId, parameters: [mediaId])
        as StoreQuery<CLMedia>;
    return (await readMultiple(q)).nonNullableList;
  }

  Future<List<T>> readMultipleByQuery<T>(StoreQuery<T> q) async {
    return (await readMultiple<T>(q)).nonNullableList;
  }
}
