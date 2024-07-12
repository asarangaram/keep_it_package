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
    required this.openWizard,
    required this.delete,
    required this.share,
    required this.togglePin,
    required this.openEditor,
    required this.restoreDeleted,
    required this.replaceMedia,
    required this.cloneAndReplaceMedia,
    required this.moveToCollectionStream,
    required this.newMedia,
    required this.analyseMediaStream,
    required this.createTempFile,
    required this.onUpsertNote,
    required this.onDeleteNote,
    required this.getPreviewPath,
    required this.upsertCollection,
    required this.deleteCollection,
    required this.openCamera,
    required this.openMedia,
    required this.openCollection,
    required this.onShareFiles,
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
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool? confirmed,
  }) replaceMedia;

  final Future<bool> Function(
    List<CLMedia> selectedMedia,
    String outFile, {
    required bool? confirmed,
  }) cloneAndReplaceMedia;

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
    required List<CLMedia> media,
    required void Function({
      required List<CLMedia> mg,
    }) onDone,
  }) analyseMediaStream;

  final Future<String> Function({required String ext}) createTempFile;

  final Future<void> Function(CLMedia media, CLNote note) onUpsertNote;
  final Future<void> Function(
    CLNote note, {
    required bool? confirmed,
  }) onDeleteNote;
  final String Function(CLMedia media) getPreviewPath;

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
}
