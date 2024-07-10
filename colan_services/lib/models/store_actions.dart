import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';

import 'cl_shared_media.dart';

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
  });
  final Future<bool> Function(List<CLMedia> selectedMedia) move;
  final Future<bool> Function(List<CLMedia> selectedMedia) delete;
  final Future<bool> Function(List<CLMedia> selectedMedia) share;
  final Future<bool> Function(List<CLMedia> selectedMedia) togglePin;
  final Future<bool> Function(List<CLMedia> selectedMedia) edit;

  final Future<bool> Function(List<CLMedia> selectedMedia) restoreDeleted;

  final Future<bool> Function(List<CLMedia> selectedMedia, String outFile)
      replaceMedia;

  final Future<bool> Function(List<CLMedia> selectedMedia, String outFile)
      cloneAndReplaceMedia;

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
    required CLSharedMedia media,
    required void Function({
      required CLSharedMedia mg,
    }) onDone,
  }) analyseMediaStream;

  final Future<String> Function({required String ext}) createTempFile;

  final Future<void> Function(CLMedia media, CLNote note) onUpsertNote;
  final Future<void> Function(CLNote note) onDeleteNote;
}
