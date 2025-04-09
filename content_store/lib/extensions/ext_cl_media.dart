import 'package:store/store.dart';

extension StoreExtCLMediaList on List<StoreEntity> {
  Map<String, List<StoreEntity>> filterByDate() {
    final filterredMedia = <String, List<StoreEntity>>{};
    final noDate = <StoreEntity>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.data.createDate != null) {
        formattedDate = entry.data.createDate!.toDisplayFormat(dataOnly: true);
        if (!filterredMedia.containsKey(formattedDate)) {
          filterredMedia[formattedDate] = [];
        }
        filterredMedia[formattedDate]!.add(entry);
      } else {
        formattedDate =
            '${entry.data.addedDate.toDisplayFormat(dataOnly: true)} '
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
