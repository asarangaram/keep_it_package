import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';

import '../models/item.dart';

extension FilterItem on Items {
  Map<String, Items> filterByDate() {
    final filterredMedia = <String, List<CLMedia>>{};
    for (final entry in entries) {
      final String formattedDate;
      if (entry.createdDate != null) {
        formattedDate = DateFormat('dd MMMM yyyy').format(entry.createdDate!);
      } else {
        formattedDate = 'No Date';
      }

      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }
    final result = <String, Items>{};
    for (final mapEntry in filterredMedia.entries) {
      result[mapEntry.key] =
          Items(collection: collection, entries: mapEntry.value);
    }
    return result;
  }
}
