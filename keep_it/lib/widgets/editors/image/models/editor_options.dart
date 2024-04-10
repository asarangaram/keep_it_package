// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class AspectRatio {
  const AspectRatio({
    required this.title,
    this.ratio,
  });
  final String title;
  final double? ratio;

  AspectRatio copyWith({
    String? title,
    double? ratio,
  }) {
    return AspectRatio(
      title: title ?? this.title,
      ratio: ratio ?? this.ratio,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'title': title,
      'ratio': ratio,
    };
  }

  factory AspectRatio.fromMap(Map<String, dynamic> map) {
    return AspectRatio(
      title: map['title'] as String,
      ratio: map['ratio'] != null ? map['ratio'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory AspectRatio.fromJson(String source) =>
      AspectRatio.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'AspectRatio(title: $title, ratio: $ratio)';

  @override
  bool operator ==(covariant AspectRatio other) {
    if (identical(this, other)) return true;

    return other.title == title && other.ratio == ratio;
  }

  @override
  int get hashCode => title.hashCode ^ ratio.hashCode;
}

@immutable
class EditorOptions {
  const EditorOptions({
    this.aspectRatio,
    this.isAspectRatioLandscape = true,
  });
  final AspectRatio? aspectRatio;
  final bool isAspectRatioLandscape;

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
    bool? isAspectRatioLandscape,
  }) {
    return EditorOptions(
      aspectRatio: aspectRatio ?? this.aspectRatio,
      isAspectRatioLandscape: isAspectRatioLandscape ?? this.isAspectRatioLandscape,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aspectRatio': aspectRatio?.toMap(),
      'isAspectRatioLandscape': isAspectRatioLandscape,
    };
  }

  factory EditorOptions.fromMap(Map<String, dynamic> map) {
    return EditorOptions(
      aspectRatio: map['aspectRatio'] != null ? AspectRatio.fromMap(map['aspectRatio'] as Map<String,dynamic>) : null,
      isAspectRatioLandscape: map['isAspectRatioLandscape'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory EditorOptions.fromJson(String source) =>
      EditorOptions.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'EditorOptions(aspectRatio: $aspectRatio, isAspectRatioLandscape: $isAspectRatioLandscape)';

  @override
  bool operator ==(covariant EditorOptions other) {
    if (identical(this, other)) return true;
  
    return 
      other.aspectRatio == aspectRatio &&
      other.isAspectRatioLandscape == isAspectRatioLandscape;
  }

  @override
  int get hashCode => aspectRatio.hashCode ^ isAspectRatioLandscape.hashCode;
}
