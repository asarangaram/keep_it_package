import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class ConfirmDelete {
  static Future<bool?> template(
    BuildContext context, {
    required String title,
    required String message,
    Widget? child,
    Future<bool?> Function()? onConfirm,
  }) async =>
      showDialog<bool?>(
        context: context,
        builder: (BuildContext context) => AlertDialog(
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
      );

  static Future<bool?> collection(
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

  static Future<bool?> media(
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

  static Future<bool?> mediaMultiple(
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
      msg = 'Are you sure you want to delete '
          'this ${media[0].type.name}?';
    } else {
      msg = 'Are you sure you want to delete the following media + '
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
}
