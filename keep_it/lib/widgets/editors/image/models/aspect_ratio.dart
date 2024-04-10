import 'package:flutter/foundation.dart';

@immutable
class AspectRatio {
  const AspectRatio({
    required this.title,
    this.ratio,
    this.isLandscape = false,
  });

  factory AspectRatio.fromMap(Map<String, dynamic> map) {
    return AspectRatio(
      title: map['title'] as String,
      ratio: map['ratio'] != null ? map['ratio'] as double : null,
      isLandscape: map['isLandscape'] as bool,
    );
  }
  final String title;
  final double? ratio;
  final bool isLandscape;

  AspectRatio copyWith({
    String? title,
    double? ratio,
    bool? isLandscape,
  }) {
    return AspectRatio(
      title: title ?? this.title,
      ratio: ratio ?? this.ratio,
      isLandscape: isLandscape ?? this.isLandscape,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'ratio': ratio,
      'isLandscape': isLandscape,
    };
  }

  @override
  String toString() =>
      'AspectRatio(title: $title, ratio: $ratio, isLandscape: $isLandscape)';

  @override
  bool operator ==(covariant AspectRatio other) {
    if (identical(this, other)) return true;

    return other.title == title &&
        other.ratio == ratio &&
        other.isLandscape == isLandscape;
  }

  @override
  int get hashCode => title.hashCode ^ ratio.hashCode ^ isLandscape.hashCode;

  bool get hasOrientation => ratio != null && ratio != 1;

  double? get aspectRatio => ratio == null
      ? null
      : isLandscape
          ? ratio!
          : (1 / ratio!);
}
