import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';

@immutable
class StoreActions {
  const StoreActions({
    required this.move,
    required this.delete,
    required this.share,
    required this.togglePin,
    required this.edit,
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
  });
  final Future<bool> Function(List<CLMedia> selectedMedia) move;
  final Future<bool> Function(
    List<CLMedia> selectedMedia, {
    required bool? confirmed,
  }) delete;
  final Future<bool> Function(List<CLMedia> selectedMedia) share;
  final Future<bool> Function(List<CLMedia> selectedMedia) togglePin;
  final Future<bool> Function(List<CLMedia> selectedMedia) edit;

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
}
