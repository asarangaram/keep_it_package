import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class Navigators {
  static Future<bool?> openCamera(
    BuildContext context, {
    int? collectionId,
  }) async {
    return null;
  }

  static Future<CLMedia?> openEditor(
    BuildContext context,
    CLMedia media, {
    bool canDuplicateMedia = true,
  }) async {
    return null;
  }

  static Future<Collection?> openCollection(
    BuildContext context,
    int collectionId,
  ) async {
    return null;
  }

  static Future<CLMedia?> openMedia(
    BuildContext context,
    int mediaId, {
    required String parentIdentifier,
    required ActionControl actionControl,
    int? collectionId,
  }) async {
    return null;
  }
}
