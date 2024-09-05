import 'package:store/store.dart';

import '../models/media_with_details.dart';

extension IndexExtonList<T> on List<T> {
  List<T> replaceNthEntry(int index, T newValue) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length);
    }

    return [
      ...sublist(0, index), // Elements before the index
      newValue, // New value at the index
      ...sublist(index + 1), // Elements after the index
    ];
  }
}

extension IndexExtonNullableList<T> on List<T?> {
  List<T> get nonNullableList {
    return where((e) => e != null).map((e) => e!).toList();
  }
}

extension ExtIterableMediaWithDetails on Iterable<MediaWithDetails> {
  List<CLMedia> toSortedMediaOnly() => map((e) => e.media).toList()
    ..sort((a, b) {
      final aDate = a.originalDate ?? a.createdDate;
      final bDate = b.originalDate ?? b.createdDate;

      if (aDate != null && bDate != null) {
        return bDate.compareTo(aDate);
      }
      return 0;
    });
}
