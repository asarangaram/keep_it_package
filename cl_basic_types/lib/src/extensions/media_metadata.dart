import 'package:meta/meta.dart';

@immutable
class MediaMetaData {
  const MediaMetaData({required this.originalDate});
  final DateTime originalDate;

  MediaMetaData copyWith({DateTime? originalDate}) {
    return MediaMetaData(originalDate: originalDate ?? this.originalDate);
  }

  @override
  String toString() => 'MediaMetaData(originalDate: $originalDate)';

  @override
  bool operator ==(covariant MediaMetaData other) {
    if (identical(this, other)) return true;

    return other.originalDate == originalDate;
  }

  @override
  int get hashCode => originalDate.hashCode;
}
