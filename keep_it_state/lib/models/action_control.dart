// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:store/store.dart';

import 'platform_support.dart';

@immutable
class ActionControl {
  const ActionControl({
    this.allowEdit = false,
    this.allowDelete = false,
    this.allowMove = false,
    this.allowShare = false,
    this.allowPin = false,
    this.allowDuplicateMedia = false,
    this.allowDeleteLocalCopy = false,
    this.allowDownload = false,
    this.allowUpload = false,
    this.allowDeleteServerCopy = false,
  });

  factory ActionControl.fromMap(Map<String, dynamic> map) {
    return ActionControl(
      allowEdit: map['allowEdit'] as bool,
      allowDelete: map['allowDelete'] as bool,
      allowMove: map['allowMove'] as bool,
      allowShare: map['allowShare'] as bool,
      allowPin: map['allowPin'] as bool,
      allowDuplicateMedia: map['canDuplicateMedia'] as bool,
    );
  }

  factory ActionControl.fromJson(String source) =>
      ActionControl.fromMap(json.decode(source) as Map<String, dynamic>);

  final bool allowEdit;
  final bool allowDelete;
  final bool allowMove;
  final bool allowShare;
  final bool allowPin;
  final bool allowDuplicateMedia;
  final bool allowDeleteLocalCopy;
  final bool allowDownload;
  final bool allowUpload;
  final bool allowDeleteServerCopy;

  ActionControl copyWith({
    bool? allowEdit,
    bool? allowDelete,
    bool? allowMove,
    bool? allowShare,
    bool? allowPin,
    bool? allowDuplicateMedia,
    bool? allowDeleteLocalCopy,
    bool? allowDownload,
    bool? allowUpload,
    bool? allowDeleteServerCopy,
  }) {
    return ActionControl(
      allowEdit: allowEdit ?? this.allowEdit,
      allowDelete: allowDelete ?? this.allowDelete,
      allowMove: allowMove ?? this.allowMove,
      allowShare: allowShare ?? this.allowShare,
      allowPin: allowPin ?? this.allowPin,
      allowDuplicateMedia: allowDuplicateMedia ?? this.allowDuplicateMedia,
      allowDeleteLocalCopy: allowDeleteLocalCopy ?? this.allowDeleteLocalCopy,
      allowDownload: allowDownload ?? this.allowDownload,
      allowUpload: allowUpload ?? this.allowUpload,
      allowDeleteServerCopy:
          allowDeleteServerCopy ?? this.allowDeleteServerCopy,
    );
  }

  @override
  String toString() {
    return 'ActionControl(allowEdit: $allowEdit, allowDelete: $allowDelete, allowMove: $allowMove, allowShare: $allowShare, allowPin: $allowPin, canDuplicateMedia: $allowDuplicateMedia, canDeleteLocalCopy: $allowDeleteLocalCopy, canKeepOffline: $allowDownload, cabUpload: $allowUpload, canDeleteServerCopy: $allowDeleteServerCopy)';
  }

  @override
  bool operator ==(covariant ActionControl other) {
    if (identical(this, other)) return true;

    return other.allowEdit == allowEdit &&
        other.allowDelete == allowDelete &&
        other.allowMove == allowMove &&
        other.allowShare == allowShare &&
        other.allowPin == allowPin &&
        other.allowDuplicateMedia == allowDuplicateMedia &&
        other.allowDeleteLocalCopy == allowDeleteLocalCopy &&
        other.allowDownload == allowDownload &&
        other.allowUpload == allowUpload &&
        other.allowDeleteServerCopy == allowDeleteServerCopy;
  }

  @override
  int get hashCode {
    return allowEdit.hashCode ^
        allowDelete.hashCode ^
        allowMove.hashCode ^
        allowShare.hashCode ^
        allowPin.hashCode ^
        allowDuplicateMedia.hashCode ^
        allowDeleteLocalCopy.hashCode ^
        allowDownload.hashCode ^
        allowUpload.hashCode ^
        allowDeleteServerCopy.hashCode;
  }

  Future<bool?> Function()? onEdit(Future<bool?> Function()? cb) =>
      allowEdit ? cb : null;
  Future<bool?> Function()? onDelete(Future<bool?> Function()? cb) =>
      allowDelete ? cb : null;
  Future<bool?> Function()? onMove(Future<bool?> Function()? cb) =>
      allowMove ? cb : null;
  Future<bool?> Function()? onShare(Future<bool?> Function()? cb) =>
      allowShare ? cb : null;
  Future<bool?> Function()? onPin(Future<bool?> Function()? cb) =>
      allowPin ? cb : null;
  Future<bool?> Function()? onDeleteLocalCopy(Future<bool?> Function()? cb) =>
      allowDeleteLocalCopy ? cb : null;
  Future<bool?> Function()? onKeepOffline(Future<bool?> Function()? cb) =>
      allowDownload ? cb : null;
  Future<bool?> Function()? onUpload(Future<bool?> Function()? cb) =>
      allowUpload ? cb : null;
  Future<bool?> Function()? onDeleteServerCopy(Future<bool?> Function()? cb) =>
      allowDeleteServerCopy ? cb : null;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'allowEdit': allowEdit,
      'allowDelete': allowDelete,
      'allowMove': allowMove,
      'allowShare': allowShare,
      'allowPin': allowPin,
      'canDuplicateMedia': allowDuplicateMedia,
    };
  }

  String toJson() => json.encode(toMap());

  static ActionControl actionControlNone() {
    return const ActionControl();
  }

  static ActionControl onGetCollectionActionControl(
    Collection collection,
    bool hasOnlineService, {
    List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) {
    final media = onGetChildren?.call(collection) ?? [];
    final canSync = hasOnlineService;
    final haveItOffline = collection.haveItOffline;

    final canDownload = canSync && collection.hasServerUID && !haveItOffline;
    final canUpload = canSync && !collection.hasServerUID;
    return ActionControl(
        allowEdit: true,
        allowDelete: true,
        allowMove: false,
        allowShare: false,
        allowPin: false,
        allowDuplicateMedia: false,
        allowDeleteLocalCopy: canSync &&
            collection.hasServerUID &&
            haveItOffline &&
            (media.any((e) => (e as CLMedia).isMediaCached)),
        allowDownload: canDownload,
        allowUpload: canUpload,
        allowDeleteServerCopy: canSync && collection.hasServerUID);
  }

  static ActionControl onGetMediaActionControl(
      CLMedia media, Collection parentCollection, bool hasOnlineService) {
    final canSync = hasOnlineService;
    final canDeleteLocalCopy = canSync &&
        parentCollection.haveItOffline &&
        media.hasServerUID &&
        media.isMediaCached;
    final haveItOffline = switch (media.haveItOffline) {
      null => parentCollection.haveItOffline,
      true => true,
      false => parentCollection.haveItOffline
    };
    final canDownload =
        canSync && media.hasServerUID && !media.isMediaCached && haveItOffline;

    final editSupported = switch (media.type) {
      CLMediaType.text => false,
      CLMediaType.image => true,
      CLMediaType.video => ColanPlatformSupport.isMobilePlatform,
      CLMediaType.url => false,
      CLMediaType.audio => false,
      CLMediaType.file => false,
    };

    return ActionControl(
        allowEdit: editSupported && media.isMediaLocallyAvailable,
        allowDelete: true,
        allowMove: true,
        allowShare: media.isMediaLocallyAvailable,
        allowPin: ColanPlatformSupport.isMobilePlatform &&
            media.isMediaLocallyAvailable,
        allowDuplicateMedia: true,
        allowDeleteLocalCopy: canDeleteLocalCopy,
        allowDownload: canDownload,
        allowUpload: canSync,
        allowDeleteServerCopy: canSync && media.hasServerUID);
  }
}
