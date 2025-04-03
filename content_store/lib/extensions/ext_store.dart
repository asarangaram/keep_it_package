import 'package:store/store.dart';

extension StoreReaderExt on StoreReader {
  Future<List<T>> readMultipleByQuery<T>(StoreQuery<T> q) async {
    return (await readMultiple<T>(q)).nonNullableList;
  }
}
