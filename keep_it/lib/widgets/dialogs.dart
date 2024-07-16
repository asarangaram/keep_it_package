import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'store_manager.dart';

class ConfirmAction {
  static Future<bool?> template(
    BuildContext context, {
    required String title,
    required String message,
    Widget? child,
    Future<bool?> Function()? onConfirm,
  }) async =>
      showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => StoreManager(
          child: AlertDialog(
            alignment: Alignment.center,
            title: Text(title),
            content: (child != null || message.isNotEmpty)
                ? SizedBox.square(
                    dimension: 200,
                    child: Column(
                      children: [
                        Flexible(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: child ?? const SizedBox.shrink(),
                            ),
                          ),
                        ),
                        if (message.isNotEmpty) Text(message),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
            actions: [
              ButtonBar(
                alignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    child: const Text('Yes'),
                    onPressed: () async {
                      await onConfirm?.call();
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  static Future<bool?> deleteCollection(
    BuildContext context, {
    required Collection collection,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            '"${collection.label}" and its content?',
        onConfirm: onConfirm,
      );

  static Future<bool?> deleteMedia(
    BuildContext context, {
    required CLMedia media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            'this ${media.type.name}?',
        onConfirm: onConfirm,
        child: getPreview(media),
      );

  static Future<bool?> deleteMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return ConfirmAction.deleteMedia(
        context,
        media: media[0],
        getPreview: getPreview,
        onConfirm: onConfirm,
      );
    } else {
      msg = 'Are you sure you want to delete the above media + '
          '${media.length - 1} items?';
    }

    return template(
      context,
      title: 'Confirm Delete',
      message: msg,
      onConfirm: onConfirm,
      child: getPreview(media[0]),
    );
  }

  static Future<bool?> permanentlyDeleteMedia(
    BuildContext context, {
    required CLMedia media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to PERMANENTLY delete '
            'this ${media.type.name}?',
        onConfirm: onConfirm,
        child: getPreview(media),
      );

  static Future<bool?> permanentlyDeleteMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    final String msg;
    if (media.length == 1) {
      return ConfirmAction.permanentlyDeleteMedia(
        context,
        media: media[0],
        getPreview: getPreview,
        onConfirm: onConfirm,
      );
    } else {
      msg = 'Are you sure you want to PERMANENTLY delete the above media + '
          '${media.length - 1} items?';
    }

    return template(
      context,
      title: 'Confirm Delete',
      message: msg,
      onConfirm: onConfirm,
      child: getPreview(media[0]),
    );
  }

  static Future<bool?> restoreMedia(
    BuildContext context, {
    required CLMedia media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Restore',
        message: 'Are you sure you want to restore '
            'this ${media.type.name}?',
        onConfirm: onConfirm,
        child: getPreview(media),
      );

  static Future<bool?> restoreMediaMultiple(
    BuildContext context, {
    required List<CLMedia> media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async {
    if (media.isEmpty) {
      return false;
    }
    if (media.length == 1) {
      return ConfirmAction.restoreMedia(
        context,
        media: media[0],
        getPreview: getPreview,
        onConfirm: onConfirm,
      );
    }
    return template(
      context,
      title: 'Confirm Restore',
      message: 'Are you sure you want to restore the above media + '
          '${media.length - 1} items?',
      child: getPreview(media[0]),
      onConfirm: onConfirm,
    );
  }

  static Future<bool?> replaceMedia(
    BuildContext context, {
    required CLMedia media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Replace',
        message: 'This will replace the original file with the above media',
        onConfirm: onConfirm,
        child: getPreview(media),
      );
  static Future<bool?> cloneAndReplaceMedia(
    BuildContext context, {
    required CLMedia media,
    required Widget Function(CLMedia media) getPreview,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Save',
        message: 'This will save the above media as a separate copy, '
            'other propertes will be copied from original media',
        onConfirm: onConfirm,
        child: getPreview(media),
      );
  static Future<bool?> deleteNote(
    BuildContext context, {
    required CLNote note,
    Future<bool?> Function()? onConfirm,
  }) async =>
      template(
        context,
        title: 'Confirm Delete',
        message: 'Are you sure you want to delete '
            "this note? You can't recover it",
        onConfirm: onConfirm,
      );
}
