// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class ActionControl {
  final bool allowEdit;
  final bool allowDelete;
  final bool allowMove;
  final bool allowShare;
  final bool allowPin;
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
  factory ActionControl.editOnly() {
    return const ActionControl(
      allowEdit: true,
      allowDelete: true,
      allowMove: false,
      allowShare: false,
      allowPin: false,
    );
  }

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
}
