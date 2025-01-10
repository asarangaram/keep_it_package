import 'package:store/src/extensions/ext_datetime.dart';

abstract class CLEntity {
  bool get isMarkedDeleted;
  bool get isMarkedEditted;
  bool get isMarkedForUpload;
  //int? get getServerUID;
  bool isContentSame(covariant CLEntity other);

  bool get hasServerUID;
  bool isChangedAfter(CLEntity other);
  int? get entityId;

  DateTime? get entityOriginalDate;
  DateTime get entityCreatedDate;
}

extension Filter on List<CLEntity> {
  Map<String, List<CLEntity>> filterByDate() {
    final filterredMedia = <String, List<CLEntity>>{};
    final noDate = <CLEntity>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.entityOriginalDate != null) {
        formattedDate =
            entry.entityOriginalDate!.toDisplayFormat(dataOnly: true);
      } else {
        formattedDate =
            '${entry.entityCreatedDate.toDisplayFormat(dataOnly: true)} '
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
