import 'package:store/store.dart';

extension StoreExtCLMediaList on List<CLMedia> {
  Map<String, List<CLMedia>> filterByDate() {
    final filterredMedia = <String, List<CLMedia>>{};
    final noDate = <CLMedia>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.createDate != null) {
        formattedDate = entry.createDate!.toDisplayFormat(dataOnly: true);
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else {
        formattedDate = '${entry.addedDate.toDisplayFormat(dataOnly: true)} '
            '(upload date)';
      }
      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }
    if (noDate.isNotEmpty) {
      filterredMedia['No Date'] = noDate;
    }

    return filterredMedia;
  }
}

extension FilenameExtOnCLMedia on CLMedia {
  String get previewFileName => '${md5}_tn.jpeg';
  String get mediaFileName => '$md5$extension';
}
