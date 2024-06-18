// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;

@immutable
class CLDirectory {
  const CLDirectory({
    required this.label,
    required this.name,
    required this.baseDir,
    String? description,
  }) : description0 = description;
  final String label;
  final String name;
  final Directory baseDir;
  final String? description0;

  Directory get path => Directory(p.join(baseDir.path, name));
  String get pathString => path.path;
  String get description => description0 ?? label;

  CLDirectory copyWith({
    String? label,
    String? name,
    Directory? baseDir,
    String? description0,
  }) {
    return CLDirectory(
      label: label ?? this.label,
      name: name ?? this.name,
      baseDir: baseDir ?? this.baseDir,
      description: description0 ?? this.description0,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'CLDirectory(label: $label, name: $name, baseDir: $baseDir, description0: $description0)';
  }

  @override
  bool operator ==(covariant CLDirectory other) {
    if (identical(this, other)) return true;

    return other.label == label &&
        other.name == name &&
        other.baseDir == baseDir &&
        other.description0 == description0;
  }

  @override
  int get hashCode {
    return label.hashCode ^
        name.hashCode ^
        baseDir.hashCode ^
        description0.hashCode;
  }

  void create() {
    if (!path.existsSync()) {
      path.createSync(recursive: true);
    }
  }
}
