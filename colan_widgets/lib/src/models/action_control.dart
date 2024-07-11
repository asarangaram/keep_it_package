// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';

@immutable
class ActionControl {
  const ActionControl({
    required this.allowEdit,
    required this.allowDelete,
    required this.allowMove,
    required this.allowShare,
    required this.allowPin,
  });

  factory ActionControl.full() {
    return const ActionControl(
      allowEdit: true,
      allowDelete: true,
      allowMove: true,
      allowShare: true,
      allowPin: true,
    );
  }
  factory ActionControl.none() {
    return const ActionControl(
      allowEdit: false,
      allowDelete: false,
      allowMove: false,
      allowShare: false,
      allowPin: false,
    );
  }

  factory ActionControl.editOnly() {
    return const ActionControl(
      allowEdit: true,
      allowDelete: true,
      allowMove: false,
      allowShare: true,
      allowPin: false,
    );
  }
  final bool allowEdit;
  final bool allowDelete;
  final bool allowMove;
  final bool allowShare;
  final bool allowPin;

  ActionControl copyWith({
    bool? allowEdit,
    bool? allowDelete,
    bool? allowMove,
    bool? allowShare,
    bool? allowPin,
  }) {
    return ActionControl(
      allowEdit: allowEdit ?? this.allowEdit,
      allowDelete: allowDelete ?? this.allowDelete,
      allowMove: allowMove ?? this.allowMove,
      allowShare: allowShare ?? this.allowShare,
      allowPin: allowPin ?? this.allowPin,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ActionControl(allowEdit: $allowEdit, allowDelete: $allowDelete, allowMove: $allowMove, allowShare: $allowShare, AllowPin: $allowPin)';
  }

  @override
  bool operator ==(covariant ActionControl other) {
    if (identical(this, other)) return true;

    return other.allowEdit == allowEdit &&
        other.allowDelete == allowDelete &&
        other.allowMove == allowMove &&
        other.allowShare == allowShare &&
        other.allowPin == allowPin;
  }

  @override
  int get hashCode {
    return allowEdit.hashCode ^
        allowDelete.hashCode ^
        allowMove.hashCode ^
        allowShare.hashCode ^
        allowPin.hashCode;
  }

  Future<bool?> Function()? onEdit(Future<bool?> Function() cb) =>
      allowEdit ? cb : null;
  Future<bool?> Function()? onDelete(Future<bool?> Function() cb) =>
      allowDelete ? cb : null;
  Future<bool?> Function()? onMove(Future<bool?> Function() cb) =>
      allowMove ? cb : null;
  Future<bool?> Function()? onShare(Future<bool?> Function() cb) =>
      allowShare ? cb : null;
  Future<bool?> Function()? onPin(Future<bool?> Function() cb) =>
      allowPin ? cb : null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'allowEdit': allowEdit,
      'allowDelete': allowDelete,
      'allowMove': allowMove,
      'allowShare': allowShare,
      'allowPin': allowPin,
    };
  }

  factory ActionControl.fromMap(Map<String, dynamic> map) {
    return ActionControl(
      allowEdit: map['allowEdit'] as bool,
      allowDelete: map['allowDelete'] as bool,
      allowMove: map['allowMove'] as bool,
      allowShare: map['allowShare'] as bool,
      allowPin: map['allowPin'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory ActionControl.fromJson(String source) =>
      ActionControl.fromMap(json.decode(source) as Map<String, dynamic>);
}
