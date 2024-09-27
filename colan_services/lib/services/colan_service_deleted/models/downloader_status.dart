// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class DownloaderStatus {
  const DownloaderStatus({
    this.running = 0,
    this.waiting = 0,
    this.completed = 0,
    this.unknown = 0,
  });
  final int running;
  final int waiting;
  final int completed;
  final int unknown;

  int get active => running + waiting;
  int get total => active + completed;

  DownloaderStatus copyWith({
    int? running,
    int? waiting,
    int? completed,
    int? unknown,
  }) {
    return DownloaderStatus(
      running: running ?? this.running,
      waiting: waiting ?? this.waiting,
      completed: completed ?? this.completed,
      unknown: unknown ?? this.unknown,
    );
  }

  @override
  bool operator ==(covariant DownloaderStatus other) {
    if (identical(this, other)) return true;

    return other.running == running &&
        other.waiting == waiting &&
        other.completed == completed &&
        other.unknown == unknown;
  }

  @override
  int get hashCode {
    return running.hashCode ^
        waiting.hashCode ^
        completed.hashCode ^
        unknown.hashCode;
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DownloaderStatus(running: $running, waiting: $waiting, completed: $completed, unknown: $unknown)';
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'running': running.toDouble(),
      'waiting': waiting.toDouble(),
      'completed': completed.toDouble(),
      'unknown': unknown.toDouble(),
    };
  }

  Map<String, Color> get colorMap => <String, Color>{
        'running': Colors.orange,
        'waiting': Colors.white,
        'completed': Colors.blue,
        'unknown': Colors.black,
      };

  factory DownloaderStatus.fromMap(Map<String, dynamic> map) {
    return DownloaderStatus(
      running: (map['running'] as double).toInt(),
      waiting: (map['waiting'] as double).toInt(),
      completed: (map['completed'] as double).toInt(),
      unknown: (map['unknown'] as double).toInt(),
    );
  }

  String toJson() => json.encode(toMap());

  factory DownloaderStatus.fromJson(String source) =>
      DownloaderStatus.fromMap(json.decode(source) as Map<String, dynamic>);
}
