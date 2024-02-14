import 'package:colan_widgets/colan_widgets.dart';
import 'package:intl/intl.dart';

extension FilterItem on List<CLMedia> {
  Map<String, List<CLMedia>> filterByDate() {
    final filterredMedia = <String, List<CLMedia>>{};
    for (final entry in this) {
      final String formattedDate;
      if (entry.originalDate != null) {
        formattedDate = DateFormat('dd MMMM yyyy').format(entry.originalDate!);
      } else {
        formattedDate = 'No Date';
      }

      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }

    return filterredMedia;
  }
}
