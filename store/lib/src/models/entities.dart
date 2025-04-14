import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'store_entity.dart';

@immutable
class CLEntities {
  const CLEntities({
    this.entries = const [],
    this.isLoading = false,
    this.errorMsg = '',
  });
  final List<StoreEntity> entries;
  final bool isLoading;
  final String errorMsg;

  CLEntities copyWith({
    List<StoreEntity>? entries,
    bool? isLoading,
    String? errorMsg,
  }) {
    return CLEntities(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
      errorMsg: errorMsg ?? this.errorMsg,
    );
  }

  @override
  String toString() =>
      'CLEntities(entries: $entries, isLoading: $isLoading, errorMsg: $errorMsg)';

  @override
  bool operator ==(covariant CLEntities other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries) &&
        other.isLoading == isLoading &&
        other.errorMsg == errorMsg;
  }

  @override
  int get hashCode => entries.hashCode ^ isLoading.hashCode ^ errorMsg.hashCode;
}
