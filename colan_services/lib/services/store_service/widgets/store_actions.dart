// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

@immutable
class StoreActions {
  const StoreActions({
    /// Actions that opens new screens
    required this.openWizard,
    required this.openEditor,
    required this.openCamera,
    required this.openMedia,
    required this.openCollection,
    required this.shareMediaMultiple,
    required this.shareFiles,
  });
  //////////////////////////////////////////////////////////////////////////////

  /////////////////////////////////////////////////////////////////////////////////

  final Future<bool> Function(
    BuildContext ctx,
    List<CLMedia> mediaMultiple,
    UniversalMediaSource wizardType, {
    Collection? collection,
  }) openWizard;

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

  @override
  bool operator ==(covariant StoreActions other) {
    if (identical(this, other)) return true;

    return other.shareMediaMultiple == shareMediaMultiple;
  }

  @override
  int get hashCode {
    return shareMediaMultiple.hashCode;
  }
}
