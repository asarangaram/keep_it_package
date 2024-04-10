// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class AspectRatio {
  const AspectRatio({
    required this.title,
    this.ratio,
    this.isLandscape = false,
  });
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

  factory AspectRatio.fromMap(Map<String, dynamic> map) {
    return AspectRatio(
      title: map['title'] as String,
      ratio: map['ratio'] != null ? map['ratio'] as double : null,
      isLandscape: map['isLandscape'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory AspectRatio.fromJson(String source) =>
      AspectRatio.fromMap(json.decode(source) as Map<String, dynamic>);

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

@immutable
class EditorOptions {
  const EditorOptions({
    this.aspectRatio = const AspectRatio(title: 'unspecified'),
  });
  final AspectRatio aspectRatio;

  List<AspectRatio> get availableAspectRatio => const [
        AspectRatio(title: 'Freeform'),
        AspectRatio(title: '1:1', ratio: 1),
        AspectRatio(title: '4:3', ratio: 4 / 3),
        AspectRatio(title: '5:4', ratio: 5 / 4),
        AspectRatio(title: '7:5', ratio: 7 / 5),
        AspectRatio(title: '16:9', ratio: 16 / 9),
      ];

  EditorOptions copyWith({
    AspectRatio? aspectRatio,
  }) {
    return EditorOptions(
      aspectRatio: aspectRatio ?? this.aspectRatio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aspectRatio': aspectRatio.toMap(),
    };
  }

  factory EditorOptions.fromMap(Map<String, dynamic> map) {
    return EditorOptions(
      aspectRatio:
          AspectRatio.fromMap(map['aspectRatio'] as Map<String, dynamic>),
    );
  }

  String toJson() => json.encode(toMap());

  factory EditorOptions.fromJson(String source) =>
      EditorOptions.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'EditorOptions(aspectRatio: $aspectRatio)';

  @override
  bool operator ==(covariant EditorOptions other) {
    if (identical(this, other)) return true;

    return other.aspectRatio == aspectRatio;
  }

  @override
  int get hashCode => aspectRatio.hashCode;
}
