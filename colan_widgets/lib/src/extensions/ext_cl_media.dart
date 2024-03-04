import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';

extension ExtCLMediaList on List<CLMedia> {
  Map<String, List<CLMedia>> filterByDate() {
    sort((a, b) {
      if (a.createdDate != null && b.createdDate != null) {
        return a.createdDate!.compareTo(b.createdDate!);
      }
      return 0;
    });

    final filterredMedia = <String, List<CLMedia>>{};
    final noDate = <CLMedia>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.originalDate != null) {
        formattedDate = DateFormat('dd MMMM yyyy').format(entry.originalDate!);
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else if (entry.createdDate != null) {
        formattedDate =
            '${DateFormat('dd MMMM yyyy').format(entry.createdDate!)} '
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
