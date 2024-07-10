import 'package:colan_services/colan_services.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/texts.dart';

class AlbumManagerHelper {
  factory AlbumManagerHelper() => _instance;
  AlbumManagerHelper._({required this.albumManager});

  static final AlbumManagerHelper _instance = AlbumManagerHelper._(
    albumManager: AlbumManager(
      albumName: 'KeepIt',
    ),
  );

  final AlbumManager albumManager;

  Future<bool> removeMedia(
    BuildContext context,
    WidgetRef ref,
    String ids,
  ) async {
    final res = await albumManager.removeMedia(ids);
    if (!res) {
      if (context.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              CLTexts.missingdDeletePermissionsForGallery,
            );
      }
    }
    return res;
  }

  Future<bool> removeMultipleMedia(
    BuildContext context,
    WidgetRef ref,
    List<String> ids,
  ) async {
    final res = await albumManager.removeMultipleMedia(ids);
    if (!res) {
      if (context.mounted) {
        await ref
            .read(
              notificationMessageProvider.notifier,
            )
            .push(
              CLTexts.missingdDeletePermissionsForGallery,
            );
      }
    }
    return res;
  }
}
