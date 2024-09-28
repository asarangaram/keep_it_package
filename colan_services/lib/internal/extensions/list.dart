import 'package:store/store.dart';

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

extension Filter on List<CLMedia> {
  Map<String, List<CLMedia>> filterByDate() {
    final filterredMedia = <String, List<CLMedia>>{};
    final noDate = <CLMedia>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.originalDate != null) {
        formattedDate = entry.originalDate!.toDisplayFormat(dataOnly: true);
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else if (entry.createdDate != null) {
        formattedDate = '${entry.createdDate!.toDisplayFormat(dataOnly: true)} '
            '(upload date)';
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else {
        noDate.add(entry);
      }
    }
    if (noDate.isNotEmpty) {
      filterredMedia['No Date'] = noDate;
    }

    return filterredMedia;
  }
}
