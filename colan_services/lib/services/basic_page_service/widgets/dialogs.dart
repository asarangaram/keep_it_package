import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class DialogService {
  static Future<bool?> template(
    BuildContext context,
    WidgetRef ref, {
    required String title,
    required String message,
  }) async =>
      showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          alignment: Alignment.center,
          title: Text(title),
          content: SizedBox.square(
            dimension: 200,
            child: Text(message),
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
    BuildContext context,
    WidgetRef ref, {
    required Collection collection,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            '"${collection.label}" and its content?',
      );

  static Future<bool?> deleteMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            'this ${media.type.name}?',
      );

  static Future<bool?> deleteMediaMultiple(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return DialogService.deleteMedia(
        context,
        ref,
        media: media[0],
      );
    } else {
      msg = 'Are you sure you want to delete ${media.length} items?';
    }

    return template(
      context,
      ref,
      title: 'Confirm Delete',
      message: msg,
    );
  }

  static Future<bool?> permanentlyDeleteMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Delete',
        message: 'Are you sure you want to PERMANENTLY delete '
            'this ${media.type.name}?',
      );

  static Future<bool?> permanentlyDeleteMediaMultiple(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return DialogService.permanentlyDeleteMedia(
        context,
        ref,
        media: media[0],
      );
    } else {
      msg =
          'Are you sure you want to PERMANENTLY delete  ${media.length} items?';
    }

    return template(
      context,
      ref,
      title: 'Confirm Delete',
      message: msg,
    );
  }

  static Future<bool?> restoreMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Restore',
        message: 'Are you sure you want to restore '
            'this ${media.type.name}?',
      );

  static Future<bool?> restoreMediaMultiple(
    BuildContext context,
    WidgetRef ref, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    if (media.length == 1) {
      return DialogService.restoreMedia(
        context,
        ref,
        media: media[0],
      );
    }
    return template(
      context,
      ref,
      title: 'Confirm Restore',
      message: 'Are you sure you want to restore  ${media.length} items?',
    );
  }

  static Future<bool?> replaceMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Replace',
        message: 'This will replace the original file with the above media',
      );
  static Future<bool?> cloneAndReplaceMedia(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia media,
  }) async =>
      template(
        context,
        ref,
        title: 'Save',
        message: 'This will save the above media as a separate copy, '
            'other propertes will be copied from original media',
      );
  static Future<bool?> deleteNote(
    BuildContext context,
    WidgetRef ref, {
    required CLMedia note,
  }) async =>
      template(
        context,
        ref,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            "this note? You can't recover it",
      );
}
