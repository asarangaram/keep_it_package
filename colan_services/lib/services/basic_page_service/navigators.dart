import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../camera_service/cl_camera_service.dart';
import '../camera_service/theme/default_theme.dart';
import '../notification_services/provider/notify.dart';

class Navigators {
  static Future<bool?> openCamera(
    BuildContext context, {
    int? collectionId,
  }) async {
    await CLCameraService.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          await Navigator.pushNamed(
            context,
            collectionId == null
                ? '/camera'
                : '/camera?collectionId=$collectionId',
          );
        }
      },
      themeData: DefaultCLCameraIcons(),
    );
    return null;
  }

  static Future<CLMedia?> openEditor(
    BuildContext context,
    WidgetRef ref,
    CLMedia media, {
    bool canDuplicateMedia = true,
  }) async {
    if (media.pin != null) {
      await ref.read(notificationMessageProvider.notifier).push(
            "Unpin to edit.\n Pinned items can't be edited",
          );
      return media;
    } else {
      final edittedMedia = await Navigator.pushNamed<CLMedia>(
        context,
        '/mediaEditor?id=${media.id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
      );
      return edittedMedia ?? media;
    }
  }

  static Future<Collection?> openCollection(
    BuildContext context,
    int collectionId,
  ) async {
    await Navigator.pushNamed(
      context,
      '/items_by_collection?id=$collectionId',
    );
    return null;
  }

  static Future<CLMedia?> openMedia(
    BuildContext context,
    int mediaId, {
    required String parentIdentifier,
    int? collectionId,
  }) async {
    final queryMap = [
      'parentIdentifier="$parentIdentifier"',
      if (collectionId != null) 'collectionId=$collectionId',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';

    await Navigator.pushNamed(context, '/media?id=$mediaId&$query');
    return null;
  }
}
