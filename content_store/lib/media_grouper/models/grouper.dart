import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../view_modifiers/models/view_modifier.dart';

enum GroupTypes {
  none,
  byOriginalDate;

  String get label =>
      switch (this) { none => 'None', byOriginalDate => 'Original Date' };
}

@immutable
class GroupBy implements ViewModifier {
  const GroupBy({
    this.method = GroupTypes.none,
    this.numColumns = 3,
  });

  final GroupTypes method;
  final int numColumns;

  GroupBy copyWith({
    GroupTypes? method,
    int? numColumns,
  }) {
    return GroupBy(
      method: method ?? this.method,
      numColumns: numColumns ?? this.numColumns,
    );
  }

  @override
  String toString() => 'GroupBy(method: $method, numColumns: $numColumns)';

  @override
  bool operator ==(covariant GroupBy other) {
    if (identical(this, other)) return true;

    return other.method == method && other.numColumns == numColumns;
  }

  @override
  int get hashCode => method.hashCode ^ numColumns.hashCode;

  @override
  bool get isActive => false;

  @override
  String get name => 'Group By';

  List<GalleryGroupCLEntity<CLEntity>> getGrouped(List<CLEntity> entities) {
    return switch (method) {
      GroupTypes.none => entities.group(numColumns),
      GroupTypes.byOriginalDate => entities.groupByTime(numColumns),
    };
  }
}

/* if (reader != null) {
      final ids = entities
          .map((e) => (e as CLMedia).collectionId)
          .where((e) => e != null)
          .map((e) => e!)
          .toSet()
          .toList();
      if (ids.length > 1) {
        final collections = await reader!.getCollectionsByIDList(ids);
        final grouped = collections.group(columns);
        result['Collections'] = grouped;
      }
    } */
