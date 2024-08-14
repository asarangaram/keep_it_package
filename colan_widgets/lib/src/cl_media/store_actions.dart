// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../models/action_control.dart';

import '../models/progress.dart';
import '../models/universal_media_source.dart';

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
    required this.deleteMediaMultiple,
    required this.permanentlyDeleteMediaMultiple,
    required this.restoreMediaMultiple,
    required this.pinMediaMultiple,
    required this.removePinMediaMultiple,
    required this.togglePinMultiple,

    /// fetch
    required this.getMediaMultipleByIds,
    required this.getPreviewPath,
    required this.getMediaPath,
    required this.getMediaLabel,
    required this.getNotesPath,
    required this.getText,

    /// Notes
    required this.upsertNote,
    required this.deleteNote, // Streams when processing in bulk
    required this.moveToCollectionStream,
    required this.newMediaMultipleStream,
    required this.shareMediaMultiple,
    required this.shareFiles,

    /// Working with file system
    required this.createTempFile,
    required this.createBackupFile, // Refresh logic
    required this.reloadStore,
  });
  //////////////////////////////////////////////////////////////////////////////

  final Future<Collection> Function(Collection collection) upsertCollection;

  /// collection == null - interpreted as temp Media
  final Future<CLMedia?> Function(
    String path, {
    required bool isVideo,
    Collection? collection,
  }) newMedia;
  final Stream<Progress> Function({
    required List<CLMediaFile> mediaFiles,
    required void Function({
      required List<CLMedia> mediaMultiple,
    }) onDone,
  }) newMediaMultipleStream;

  // For replacing path:

  final Future<CLMedia> Function(
    BuildContext ctx,
    CLMedia media,
    String outFile,
  ) replaceMedia;

  final Future<CLMedia> Function(
    BuildContext ctx,
    CLMedia media,
    String outFile,
  ) cloneAndReplaceMedia;

  // replace collectionId
  final Stream<Progress> Function(
    List<CLMedia> mediaMultiple, {
    required Collection collection,
    required void Function() onDone,
  }) moveToCollectionStream;

  // update Pin
  final Future<bool> Function(BuildContext ctx, List<CLMedia> mediaMultiple)
      removePinMediaMultiple;
  final Future<bool> Function(BuildContext ctx, List<CLMedia> mediaMultiple)
      pinMediaMultiple;
  final Future<bool> Function(BuildContext ctx, List<CLMedia> mediaMultiple)
      togglePinMultiple;

  final Future<void> Function(
    String path, // Absolute Path, can't go to CLNote
    CLNoteTypes type, {
    required List<CLMedia> mediaMultiple,
    CLNote? note,
  }) upsertNote;

  /////////////////////////////////////////////////////////////////////////////////
  final Future<bool> Function(
    BuildContext ctx,
    Collection collection,
  ) deleteCollection;

  final Future<bool> Function(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) deleteMediaMultiple;

  final Future<bool> Function(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) permanentlyDeleteMediaMultiple;

  final Future<bool> Function(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
  ) restoreMediaMultiple;

  final Future<void> Function(BuildContext ctx, CLNote note) deleteNote;

  /////////////////////////////////////////////////////////////////////////////////

  final Future<bool> Function(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
    UniversalMediaSource wizardType, {
    Collection? collection,
  }) openWizard;

  final Future<String> Function({required String ext}) createTempFile;
  final String Function(CLMedia media) getPreviewPath;
  final String Function(CLMedia media) getMediaPath;
  final String Function(CLMedia media) getMediaLabel;
  final String Function(CLNote media) getNotesPath;
  final String Function(CLTextNote? note) getText;

  // Opens New page
  final Future<void> Function(BuildContext ctx, {int? collectionId}) openCamera;
  final Future<void> Function(
    int mediaId, {
    required ActionControl actionControl,
    int? collectionId,
    String? parentIdentifier,
  }) openMedia;
  final Future<CLMedia> Function(
    BuildContext ctx,
    CLMedia media, {
    required bool canDuplicateMedia,
  }) openEditor;

  final Future<void> Function(
    BuildContext ctx, {
    int? collectionId,
  }) openCollection;

  final Future<bool> Function(BuildContext ctx, List<CLMedia> mediaMultiple)
      shareMediaMultiple;

  final Future<void> Function(
    BuildContext ctx,
    List<String> files, {
    Rect? sharePositionOrigin,
  }) shareFiles;

  final Future<String> Function() createBackupFile;

  final Future<void> Function() reloadStore;
  final Future<List<CLMedia?>> Function(List<int> ids) getMediaMultipleByIds;

  @override
  bool operator ==(covariant StoreActions other) {
    if (identical(this, other)) return true;

    return other.upsertCollection == upsertCollection &&
        other.pinMediaMultiple == pinMediaMultiple &&
        other.getPreviewPath == getPreviewPath &&
        other.getMediaPath == getMediaPath &&
        other.getMediaLabel == getMediaLabel &&
        other.shareMediaMultiple == shareMediaMultiple &&
        other.createBackupFile == createBackupFile &&
        other.reloadStore == reloadStore;
  }

  @override
  int get hashCode {
    return upsertCollection.hashCode ^
        pinMediaMultiple.hashCode ^
        getPreviewPath.hashCode ^
        getMediaPath.hashCode ^
        getMediaLabel.hashCode ^
        shareMediaMultiple.hashCode ^
        createBackupFile.hashCode ^
        reloadStore.hashCode;
  }
}
