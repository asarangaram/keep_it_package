import '../models/cl_media.dart';
import 'ext_datetime.dart';

extension ExtCLMediaList on List<CLMedia> {
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
