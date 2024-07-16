// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'action_control.dart';
import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';
import 'progress.dart';
import 'universal_media_source.dart';

@immutable
class StoreActions {
  const StoreActions({
    /// Actions that opens new screens
    required this.openWizard,
    required this.openEditor,
    required this.openCamera,
    required this.openMedia,
    required this.openCollection,

    /// Actions that handle the database
    /// Collection
    required this.upsertCollection,
    required this.deleteCollection,

    /// Media - needs improvement
    required this.newMedia,
    required this.replaceMedia,
    required this.cloneAndReplaceMedia,
    required this.delete,
    required this.restoreDeleted,
    required this.togglePin,
    required this.getPreviewPath,
    required this.getMediaPath,
    required this.getMediaLabel,

    /// Notes
    required this.onUpsertNote,
    required this.onDeleteNote, // Streams when processing in bulk
    required this.moveToCollectionStream,
    required this.analyseMediaStream,
    required this.share,
    required this.onShareFiles,

    /// Working with file system
    required this.createTempFile,
    required this.createBackupFile, // Refresh logic
    required this.reloadStore,
  });
  final Future<bool> Function(
    List<CLMedia> media,
    UniversalMediaSource wizardType,
  ) openWizard;

  final Future<bool> Function(
    List<CLMedia> selectedMedia, {
    required bool? confirmed,
  }) delete;
  final Future<bool> Function(List<CLMedia> selectedMedia) share;
  final Future<bool> Function(List<CLMedia> selectedMedia) togglePin;
  final Future<bool> Function(
    List<CLMedia> selectedMedia, {
    required bool canDuplicateMedia,
  }) openEditor;

  final Future<bool> Function(
    List<CLMedia> selectedMedia, {
    required bool? confirmed,
  }) restoreDeleted;

  final Future<bool> Function(
    CLMedia selectedMedia,
    String outFile,
  ) replaceMedia;

  final Future<bool> Function(
    CLMedia selectedMedia,
    String outFile,
  ) cloneAndReplaceMedia;

  final Future<CLMedia?> Function(
    String path, {
    required bool isVideo,
    Collection? collection,
  }) newMedia;

  final Stream<Progress> Function(
    List<CLMedia> selectedMedia, {
    required Collection collection,
    required void Function() onDone,
  }) moveToCollectionStream;

  final Stream<Progress> Function({
    required List<CLMediaFile> mediaFiles,
    required void Function({
      required List<CLMedia> mg,
    }) onDone,
  }) analyseMediaStream;

  final Future<String> Function({required String ext}) createTempFile;

  final Future<void> Function(
    String path,
    CLNoteTypes type, {
    required List<CLMedia> media,
    CLNote? note,
  }) onUpsertNote;
  final Future<void> Function(
    CLNote note, {
    required bool? confirmed,
  }) onDeleteNote;
  final String Function(CLMedia media) getPreviewPath;
  final String Function(CLMedia media) getMediaPath;
  final String Function(CLMedia media) getMediaLabel;

  final Future<Collection> Function(Collection collection) upsertCollection;
  final Future<bool> Function(
    Collection collection, {
    required bool? confirmed,
  }) deleteCollection;

  final Future<void> Function({int? collectionId}) openCamera;

  final Future<void> Function(
    int mediaId, {
    required ActionControl actionControl,
    int? collectionId,
    String? parentIdentifier,
  }) openMedia;
  final Future<void> Function({
    int? collectionId,
  }) openCollection;

  final Future<void> Function(
    List<String> files, {
    Rect? sharePositionOrigin,
  }) onShareFiles;

  final Future<String> Function() createBackupFile;

  final Future<void> Function() reloadStore;

  @override
  bool operator ==(covariant StoreActions other) {
    if (identical(this, other)) return true;

    return other.share == share &&
        other.togglePin == togglePin &&
        other.getPreviewPath == getPreviewPath &&
        other.getMediaPath == getMediaPath &&
        other.upsertCollection == upsertCollection &&
        other.createBackupFile == createBackupFile &&
        other.reloadStore == reloadStore;
  }

  @override
  int get hashCode {
    return share.hashCode ^
        togglePin.hashCode ^
        getPreviewPath.hashCode ^
        getMediaPath.hashCode ^
        upsertCollection.hashCode ^
        createBackupFile.hashCode ^
        reloadStore.hashCode;
  }
}
