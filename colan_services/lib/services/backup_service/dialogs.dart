import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class ConfirmAction {
  static Future<bool?> template(
    BuildContext context, {
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
            ButtonBar(
              alignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                ElevatedButton(
                  child: const Text('Yes'),
                  onPressed: () async => Navigator.of(context).pop(true),
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
      );

  static Future<bool?> deleteMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            'this ${media.type.name}?',
      );

  static Future<bool?> deleteMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return ConfirmAction.deleteMedia(
        context,
        media: media[0],
      );
    } else {
      msg = 'Are you sure you want to delete ${media.length} items?';
    }

    return template(
      context,
      title: 'Confirm Delete',
      message: msg,
    );
  }

  static Future<bool?> permanentlyDeleteMedia(
    BuildContext context, {
    required CLMedia media,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to PERMANENTLY delete '
            'this ${media.type.name}?',
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
      return ConfirmAction.permanentlyDeleteMedia(
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
            'this ${media.type.name}?',
      );

  static Future<bool?> restoreMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    if (media.length == 1) {
      return ConfirmAction.restoreMedia(
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
    required CLNote note,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            "this note? You can't recover it",
      );
}
