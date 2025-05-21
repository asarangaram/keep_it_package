import 'dart:convert';

import 'package:flutter/foundation.dart';

@immutable
class UriConfig {
  const UriConfig({
    this.lastKnownPlayPosition = Duration.zero,
    this.quarterTurns = 1,
  });

  factory UriConfig.fromMap(Map<String, dynamic> map) {
    return UriConfig(
      quarterTurns: (map['quarterTurns'] ?? 0) as int,
      lastKnownPlayPosition:
          Duration(seconds: map['lastKnownPlayPosition'] as int),
    );
  }

  factory UriConfig.fromJson(String source) =>
      UriConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  final int quarterTurns;
  final Duration lastKnownPlayPosition;

  UriConfig copyWith({
    int? quarterTurns,
    Duration? lastKnownPlayPosition,
  }) {
    return UriConfig(
      quarterTurns: quarterTurns ?? this.quarterTurns,
      lastKnownPlayPosition:
          lastKnownPlayPosition ?? this.lastKnownPlayPosition,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'quarterTurns': quarterTurns,
      'lastKnownPlayPosition': lastKnownPlayPosition.inSeconds,
    };
  }

  String toJson() => json.encode(toMap());

  @override
  String toString() =>
      'UriConfig(quarterTurns: $quarterTurns, lastKnownPlayPosition: $lastKnownPlayPosition)';

  @override
  bool operator ==(covariant UriConfig other) {
    if (identical(this, other)) return true;

    return other.quarterTurns == quarterTurns &&
        other.lastKnownPlayPosition == lastKnownPlayPosition;
  }

  @override
  int get hashCode => quarterTurns.hashCode ^ lastKnownPlayPosition.hashCode;
}
