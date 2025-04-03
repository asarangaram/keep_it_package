import 'package:store/store.dart';

extension StoreExtCLMediaList on List<CLEntity> {
  Map<String, List<CLEntity>> filterByDate() {
    final filterredMedia = <String, List<CLEntity>>{};
    final noDate = <CLEntity>[];
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

extension FilenameExtOnCLMedia on CLEntity {
  String get previewFileName => '${md5}_tn.jpeg';
  String get mediaFileName => '$md5$extension';
}
