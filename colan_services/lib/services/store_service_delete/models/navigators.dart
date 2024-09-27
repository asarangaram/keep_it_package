import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../../camera_service/cl_camera_service.dart';
import '../../camera_service/theme/default_theme.dart';
import '../../notification_services/provider/notify.dart';

class Navigators {
  static Future<bool?> openCamera(
    BuildContext context, {
    int? collectionId,
  }) async {
    await CLCameraService.invokeWithSufficientPermission(
      context,
      () async {
        if (context.mounted) {
          await context.push(
            '/camera'
            '${collectionId == null ? '' : '?collectionId=$collectionId'}',
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
      final edittedMedia = await context.push<CLMedia>(
        '/mediaEditor?id=${media.id}&canDuplicateMedia=${canDuplicateMedia ? '1' : '0'}',
      );
      return edittedMedia ?? media;
    }
  }

  static Future<Collection?> openCollection(
    BuildContext context,
    int collectionId,
  ) async {
    await context.push(
      '/items_by_collection/$collectionId',
    );
    return null;
  }

  static Future<CLMedia?> openMedia(
    BuildContext context,
    int mediaId, {
    required String parentIdentifier,
    required ActionControl actionControl,
    int? collectionId,
  }) async {
    final queryMap = [
      'parentIdentifier="$parentIdentifier"',
      if (collectionId != null) 'collectionId=$collectionId',
      // ignore: unnecessary_null_comparison
      if (actionControl != null) 'actionControl=${actionControl.toJson()}',
    ];
    final query = queryMap.isNotEmpty ? '?${queryMap.join('&')}' : '';

    await context.push('/media/$mediaId$query');
    return null;
  }
}
