import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

import '../../media_view_service/preview/media_preview_service.dart';
import '../../media_view_service/widgets/cl_media_collage.dart';

class DialogService {
  static Future<bool?> template(
    BuildContext context, {
    required String title,
    required String message,
    List<CLEntity>? entity,
  }) async =>
      showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          alignment: Alignment.center,
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (entity != null && entity.isNotEmpty)
                switch (entity.first) {
                  final CLMedia _ => SizedBox.square(
                      dimension: 100,
                      child: CLMediaCollage.byMatrixSize(
                        entity.length,
                        hCount: 3,
                        vCount: 3,
                        itemBuilder: (context, index) {
                          return MediaThumbnail(
                            media: entity[index] as CLMedia,
                          );
                        },
                        whenNopreview: const Center(),
                      ),
                    ),
                  _ => throw UnimplementedError()
                },
              Text(
                message,
              ),
            ],
          ),
          actions: [
            OverflowBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async =>
                      PageManager.of(context).closeDialog(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () async =>
                      PageManager.of(context).closeDialog(true),
                ),
              ],
            ),
          ],
        ),
      );

  static Future<bool?> deleteCollection(
    BuildContext context, {
    required Collection collection,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            '"${collection.label}" and its content?',
        entity: [collection],
      );

  static Future<bool?> deleteMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            'this ${media.type}?',
        entity: [media],
      );

  static Future<bool?> deleteMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }

    if (media.length == 1) {
      return DialogService.deleteMedia(
        context,
        media: media[0],
      );
    } else {
      final String msg;

      msg = 'Are you sure you want to delete ${media.length} items?';
      return template(
        context,
        title: 'Confirm Delete',
        message: msg,
        entity: media,
      );
    }
  }

  static Future<bool?> permanentlyDeleteMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to PERMANENTLY delete '
            'this ${media.type}?',
      );

  static Future<bool?> permanentlyDeleteMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return DialogService.permanentlyDeleteMedia(
        context,
        media: media[0],
      );
    } else {
      msg =
          'Are you sure you want to PERMANENTLY delete  ${media.length} items?';
    }

    return template(
      context,
      title: 'Confirm Delete',
      message: msg,
    );
  }

  static Future<bool?> restoreMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Restore',
        message: 'Are you sure you want to restore '
            'this ${media.type}?',
      );

  static Future<bool?> restoreMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    if (media.length == 1) {
      return DialogService.restoreMedia(
        context,
        media: media[0],
      );
    }
    return template(
      context,
      title: 'Confirm Restore',
      message: 'Are you sure you want to restore  ${media.length} items?',
    );
  }

  static Future<bool?> replaceMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Replace',
        message: 'This will replace the original file with the above media',
      );
  static Future<bool?> cloneAndReplaceMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Save',
        message: 'This will save the above media as a separate copy, '
            'other propertes will be copied from original media',
      );
  static Future<bool?> deleteNote(
    BuildContext context, {
    required CLMedia note,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            "this note? You can't recover it",
      );
}
