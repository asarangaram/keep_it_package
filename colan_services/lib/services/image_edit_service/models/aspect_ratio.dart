// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  String toJson() => json.encode(toMap());

  factory AspectRatio.fromJson(String source) =>
      AspectRatio.fromMap(json.decode(source) as Map<String, dynamic>);
}

@immutable
class SupportedAspectRatio {
  const SupportedAspectRatio({
    required this.aspectRatios,
  });

  final List<AspectRatio> aspectRatios;

  SupportedAspectRatio copyWith({
    List<AspectRatio>? aspectRatios,
  }) {
    return SupportedAspectRatio(
      aspectRatios: aspectRatios ?? this.aspectRatios,
    );
  }

  @override
  String toString() => 'SupportedAspectRatio(aspectRatios: $aspectRatios)';

  @override
  bool operator ==(covariant SupportedAspectRatio other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.aspectRatios, aspectRatios);
  }

  @override
  int get hashCode => aspectRatios.hashCode;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'aspectRatios': aspectRatios.map((x) => x.toMap()).toList(),
    };
  }

  factory SupportedAspectRatio.fromMap(Map<String, dynamic> map) {
    return SupportedAspectRatio(
      aspectRatios: List<AspectRatio>.from(
        (map['aspectRatios'] as List<int>).map<AspectRatio>(
          (x) => AspectRatio.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SupportedAspectRatio.fromJson(String source) =>
      SupportedAspectRatio.fromMap(json.decode(source) as Map<String, dynamic>);

  static Future<SupportedAspectRatio> load() async {
    final prefs = await SharedPreferences.getInstance();
    final prefJSON = prefs.getString('SupportedAspectRatio');
    if (prefJSON == null) {
      const config = SupportedAspectRatiosDefault();
      await prefs.setString('SupportedAspectRatio', config.toJson());
      return config;
    }
    return SupportedAspectRatio.fromJson(prefJSON);
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('SupportedAspectRatio', toJson());
  }
}

class SupportedAspectRatiosDefault extends SupportedAspectRatio {
  const SupportedAspectRatiosDefault()
      : super(
          aspectRatios: const [
            AspectRatio(title: '1:1', ratio: 1),
            AspectRatio(title: '4:3', ratio: 4 / 3),
            AspectRatio(title: '5:4', ratio: 5 / 4),
            AspectRatio(title: '7:5', ratio: 7 / 5),
            AspectRatio(title: '16:9', ratio: 16 / 9),
          ],
        );
}

final supportedAspectRatiosProvider =
    FutureProvider<SupportedAspectRatio>((ref) async {
  return SupportedAspectRatio.load();
});
